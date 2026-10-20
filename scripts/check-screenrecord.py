#!/usr/bin/env python3
"""Check recorder lifecycle with isolated fake devices/processes, without capture.

Usage: python3 scripts/check-screenrecord.py
"""

import json
import os
from pathlib import Path
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]
STUB = r'''
import json, os, signal, socket, sys, time
from pathlib import Path

name, *args = sys.argv[1:]
stage = Path(os.environ["SCREENRECORD_TEST_DIR"])
scenario = os.environ.get("SCREENRECORD_TEST_SCENARIO", "success")

def event(kind, **values):
    data = json.dumps(dict(event=kind, pid=os.getpid(), time=time.monotonic(), **values)) + "\n"
    fd = os.open(stage / "events.jsonl", os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o600)
    os.write(fd, data.encode())
    os.close(fd)

def registered(pid):
    try:
        marker = ("SCREENRECORD_TEST_DIR=" + str(stage)).encode()
        return marker in Path(f"/proc/{pid}/environ").read_bytes().split(b"\0")
    except (FileNotFoundError, PermissionError, ProcessLookupError):
        return False

event("command", name=name, args=args)
if name == "kill":
    sig = signal.SIGTERM
    if args and args[0] == "-s":
        args.pop(0)
        sig = getattr(signal, "SIG" + args.pop(0).removeprefix("SIG"))
    elif args and args[0].startswith("-"):
        value = args.pop(0)[1:]
        sig = int(value) if value.isdigit() else getattr(signal, "SIG" + value.removeprefix("SIG"))
    args = [arg for arg in args if arg != "--"]
    for value in args:
        pid = int(value)
        if pid <= 0 or not registered(pid):
            sys.exit(1)
        try:
            os.kill(pid, sig)
        except ProcessLookupError:
            sys.exit(1)
    sys.exit(0)
if name in ("pgrep", "pkill"):
    # Never search or signal the user's session, including Waybar.
    sys.exit(1)
if name == "notify-send":
    sys.exit(0)
if name == "ffprobe":
    output = Path(args[-1])
    if scenario == "invalid-output" or not output.is_file() or not output.stat().st_size:
        sys.exit(1)
    print('{"streams":[{"codec_type":"video"}],"format":{"duration":"1.0"}}')
    sys.exit(0)
if name == "hyprctl":
    print('[{"focused":true,"scale":1}]')
    sys.exit(0)
if name == "jq":
    print("1")
    sys.exit(0)
if name == "v4l2-ctl":
    if scenario == "no-camera":
        sys.exit(1)
    print("Camera:\n\t/dev/video0" if "--list-devices" in args else "640x360 1280x720")
    sys.exit(0)
if name == "gsr-cli":
    path = args[args.index("-ipc") + 1]
    command = args[args.index("-ipc") + 2:]
    try:
        with socket.socket(socket.AF_UNIX) as client:
            client.settimeout(5)
            client.connect(path)
            if command == ["status"]:
                print("running")
                sys.exit(0)
            client.sendall((json.dumps(command) + "\n").encode())
            reply = client.makefile().readline()
        response = json.loads(reply)
        if response["result"] != "ok":
            print(response["data"], file=sys.stderr)
            sys.exit(1)
        if response.get("data"):
            print(response["data"])
        sys.exit(0)
    except (OSError, ValueError) as error:
        print(f"stub IPC failed: {error}", file=sys.stderr)
        sys.exit(1)

def stopped(signum, frame):
    if name == "ffplay" and scenario.startswith("delayed-webcam"):
        time.sleep(0.15)
    raise SystemExit(128 + signum)
signal.signal(signal.SIGTERM, stopped)
signal.signal(signal.SIGINT, stopped)
if name == "ffplay":
    event("webcam-start")
    try:
        if scenario == "webcam-failure":
            print("stub webcam open failed", file=sys.stderr)
            sys.exit(1)
        while True:
            time.sleep(0.05)
    finally:
        event("webcam-exit")

if name != "gpu-screen-recorder":
    raise SystemExit("Unexpected stub command: " + name)
event("recorder-start")
server = None
path = None
try:
    if scenario == "uncancellable":
        signal.signal(signal.SIGINT, signal.SIG_IGN)
    if scenario == "startup-failure":
        print("stub encoder initialization failed", file=sys.stderr)
        sys.exit(1)
    output = Path(args[args.index("-o") + 1])
    path = Path(args[args.index("-ipc") + 1])
    path.unlink(missing_ok=True)
    server = socket.socket(socket.AF_UNIX)
    server.bind(str(path))
    server.listen()
    # Like the real recorder, expose IPC before finishing portal/encoder setup.
    time.sleep(3 if scenario in ("pending", "uncancellable", "delayed-webcam-pending") else 0.15)
    if scenario == "cancelled":
        print("stub portal selection cancelled", file=sys.stderr)
        sys.exit(1)
    event("recorder-ready")
    while True:
        connection, _ = server.accept()
        with connection:
            message = connection.makefile().readline()
            if not message:
                continue
            command = json.loads(message)
            event("ipc", args=command)
            result = dict(result="ok")
            stopping = command == ["stop"]
            if stopping and scenario == "save-failure":
                result = dict(result="error", data="stub video save failed")
            elif stopping and scenario == "missing-output":
                result["data"] = str(output)
            elif stopping:
                output.parent.mkdir(parents=True, exist_ok=True)
                output.write_bytes(b"stub video: no real capture")
                result["data"] = str(output)
            connection.sendall((json.dumps(result) + "\n").encode())
            if stopping and result["result"] == "error":
                scenario = "success"
            elif stopping:
                sys.exit(0)
finally:
    if server:
        server.close()
    if path:
        path.unlink(missing_ok=True)
    event("recorder-exit")
'''


class ScreenrecordCheck(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="prism-screenrecord-check-", dir="/tmp")
        self.stage = Path(self.directory.name)
        for name in ("bin", "home", "runtime", "state"):
            (self.stage / name).mkdir(mode=0o700)
        source = (ROOT / "pkgs/prism-screenrecord.nix").read_text()
        body = source.split('writeShellScriptBin "prism-screenrecord" \'\'\n', 1)[1].rsplit("\n''", 1)[0]
        body = "\n".join(line for line in body.splitlines() if "export PATH=${pkgs.lib.makeBinPath deps}" not in line)
        self.script = self.stage / "prism-screenrecord"
        self.script.write_text("#!" + shutil.which("bash") + "\n" + body.replace("''${", "${") + "\n")
        self.script.chmod(0o755)
        stub = self.stage / "stub.py"
        stub.write_text(STUB)
        for name in ("gpu-screen-recorder", "gsr-cli", "ffplay", "ffprobe", "v4l2-ctl", "hyprctl", "jq", "notify-send", "pgrep", "pkill"):
            command = self.stage / "bin" / name
            command.write_text("#!/bin/sh\nexec " + " ".join(map(shlex.quote, (sys.executable, str(stub), name))) + ' "$@"\n')
            command.chmod(0o755)
        guard = self.stage / "bash-env"
        call_stub = " ".join(map(shlex.quote, (sys.executable, str(stub))))
        guard.write_text('kill() { ' + call_stub + ' kill "$@"; }\n')
        self.env = os.environ | {
            "PATH": str(self.stage / "bin") + ":" + os.environ["PATH"],
            "HOME": str(self.stage / "home"),
            "XDG_RUNTIME_DIR": str(self.stage / "runtime"),
            "XDG_STATE_HOME": str(self.stage / "state"),
            "XDG_VIDEOS_DIR": str(self.stage / "home/Videos"),
            "BASH_ENV": str(guard),
            "SCREENRECORD_TEST_DIR": str(self.stage),
        }
        self.processes = []

    def tearDown(self):
        # Every invocation has a separate, test-owned session; never signal the real desktop.
        for process in self.processes:
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
        for process in self.processes:
            process.wait(timeout=5)
        # Supervisors can finish their EXIT traps after the original launcher exits.
        for attempt in range(50):
            try:
                self.directory.cleanup()
                break
            except OSError:
                if attempt == 49:
                    raise
                time.sleep(0.025)

    def events(self, kind=None):
        path = self.stage / "events.jsonl"
        events = [json.loads(line) for line in path.read_text().splitlines()] if path.exists() else []
        return [event for event in events if kind is None or event["event"] == kind]

    def wait_for(self, predicate, message):
        deadline = time.monotonic() + 6
        while time.monotonic() < deadline:
            if predicate():
                return
            time.sleep(0.025)
        self.fail(message + "\n" + json.dumps(self.events(), indent=2))

    def launch(self, *args):
        process = subprocess.Popen([str(self.script), *args], env=self.env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
        self.processes.append(process)
        return process

    def run_command(self, *args):
        return self.launch(*args).wait(timeout=8)

    def notifications(self):
        return [event for event in self.events("command") if event["name"] == "notify-send"]

    def notified(self, text):
        return any(text.lower() in " ".join(event["args"]).lower() for event in self.notifications())

    def assert_no_success(self):
        self.assertFalse(self.notified("Recording started"), self.notifications())
        self.assertFalse(self.notified("Recording saved"), self.notifications())
        self.assertFalse(self.notified("saved successfully"), self.notifications())

    def assert_children_stopped(self):
        def stopped():
            events = self.events()
            return all(any(item["event"] == event["event"].replace("-start", "-exit") and item["pid"] == event["pid"] for item in events) for event in events if event["event"] in ("recorder-start", "webcam-start"))
        self.wait_for(stopped, "Test recorder/webcam child was left running")

    def test_ready_audio_save_and_webcam_cleanup(self):
        self.assertEqual(self.run_command("--desktop", "--mic", "--webcam"), 0)
        self.wait_for(lambda: self.notified("Recording started"), "No confirmed start notification")
        command = next(event for event in self.events("command") if event["name"] == "gpu-screen-recorder")
        args = command["args"]
        self.assertEqual(args[args.index("-a") + 1], "default_output|default_input")
        self.assertEqual(args[args.index("-w") + 1], "portal")
        ready = self.events("recorder-ready")[0]["time"]
        started = next(event for event in self.notifications() if "Recording started" in " ".join(event["args"]))
        self.assertGreaterEqual(started["time"], ready)
        self.assertEqual(self.run_command("--stop"), 0)
        self.wait_for(lambda: self.notified("saved"), "No save notification")
        self.assertTrue(any(path.stat().st_size for path in (self.stage / "home/Videos").glob("*.mp4")))
        self.assert_children_stopped()

    def test_startup_failure_cleans_webcam_without_success(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "startup-failure"
        self.run_command("--webcam")
        self.wait_for(lambda: bool(self.events("recorder-exit")), "Failed recorder did not exit")
        self.wait_for(lambda: bool(self.notifications()), "No startup failure notification")
        self.assert_children_stopped()
        self.assert_no_success()
        log = self.stage / "state/prism/screenrecord.log"
        self.assertIn("stub encoder initialization failed", log.read_text())

    def test_portal_cancelled_without_success(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "cancelled"
        self.run_command("--webcam")
        self.wait_for(lambda: bool(self.events("recorder-exit")), "Cancelled recorder did not exit")
        self.assert_children_stopped()
        self.assert_no_success()

    def test_idle_stop_does_not_start_anything(self):
        self.assertEqual(self.run_command("--stop"), 0)
        self.assertEqual(self.events("recorder-start"), [])
        self.assert_no_success()

    def test_failed_save_does_not_claim_success(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "save-failure"
        self.run_command()
        self.wait_for(lambda: self.notified("Recording started"), "Recorder did not start")
        self.assertNotEqual(self.run_command("--stop"), 0)
        self.assertFalse(self.notified("Recording saved"), self.notifications())
        self.assertFalse(self.notified("saved successfully"), self.notifications())
        self.assertTrue(self.notified("fail") or self.notified("error") or self.notified("could not confirm"), self.notifications())
        self.assertEqual(self.events("recorder-exit"), [], "A failed stop must permit retry")
        self.assertEqual(self.run_command("--stop"), 0)
        self.assert_children_stopped()

    def test_missing_output_does_not_claim_saved(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "missing-output"
        self.run_command()
        self.wait_for(lambda: self.notified("Recording started"), "Recorder did not start")
        self.assertNotEqual(self.run_command("--stop"), 0)
        self.assertFalse(self.notified("Recording saved"), self.notifications())
        self.assertFalse(self.notified("saved successfully"), self.notifications())
        self.assert_children_stopped()

    def test_stop_cancels_pending_portal(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "delayed-webcam-pending"
        self.run_command("--webcam")
        self.wait_for(lambda: bool(self.events("recorder-start")), "Recorder did not launch")
        started = time.monotonic()
        self.assertEqual(self.run_command("--stop"), 0)
        self.assertLess(time.monotonic() - started, 2, "Stop waited for portal selection")
        self.assertEqual(len(self.events("webcam-start")), len(self.events("webcam-exit")), "Pending stop returned before webcam cleanup")
        self.assert_children_stopped()
        self.assert_no_success()

    def test_failed_pending_cancel_reports_failure_and_recovers(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "uncancellable"
        self.run_command()
        self.wait_for(lambda: bool(self.events("recorder-start")), "Recorder did not launch")
        self.assertNotEqual(self.run_command("--stop"), 0)
        self.assertTrue(self.notified("Could not cancel"), self.notifications())
        self.assertFalse(self.notified("Recording cancelled"), self.notifications())
        self.wait_for(lambda: self.notified("Recording started"), "Failed cancellation prevented recording readiness")
        self.assertEqual(self.run_command("--stop"), 0)
        self.assert_children_stopped()

    def test_stale_socket_does_not_block_recording(self):
        state = self.stage / "runtime/prism-screenrecord"
        state.mkdir(mode=0o700)
        stale = socket.socket(socket.AF_UNIX)
        stale.bind(str(state / "recorder.sock"))
        stale.close()
        self.run_command()
        self.wait_for(lambda: self.notified("Recording started"), "Stale socket prevented recording")
        self.assertEqual(self.run_command("--stop"), 0)
        self.assert_children_stopped()

    def test_missing_camera_is_reported_while_screen_records(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "no-camera"
        self.run_command("--webcam")
        self.wait_for(lambda: self.notified("Recording started"), "Screen recording did not start")
        self.assertTrue(self.notified("No webcam"), self.notifications())
        self.assertEqual(self.events("webcam-start"), [])
        self.assertEqual(self.run_command("--stop"), 0)
        self.assert_children_stopped()

    def test_webcam_open_failure_is_reported(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "webcam-failure"
        self.run_command("--webcam")
        self.wait_for(lambda: self.notified("Webcam preview failed"), "Webcam failure was not reported")
        self.assertTrue(self.notified("Recording started"), self.notifications())
        self.assertEqual(self.run_command("--stop"), 0)
        self.assert_children_stopped()
        webcam_pid = str(self.events("webcam-start")[0]["pid"])
        signals = [event["args"] for event in self.events("command") if event["name"] == "kill" and webcam_pid in event["args"] and event["args"][0] != "-0"]
        self.assertEqual(signals, [], "Cleanup must not signal an exited webcam's reusable PID")

    def test_invalid_video_does_not_claim_saved(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "invalid-output"
        self.run_command()
        self.wait_for(lambda: self.notified("Recording started"), "Recorder did not start")
        self.assertNotEqual(self.run_command("--stop"), 0)
        self.assertFalse(self.notified("Recording saved"), self.notifications())
        self.assert_children_stopped()

    def test_new_recording_can_start_immediately_after_stop(self):
        self.env["SCREENRECORD_TEST_SCENARIO"] = "delayed-webcam"
        self.run_command("--webcam")
        self.wait_for(lambda: self.notified("Recording started"), "Recorder did not start")
        self.assertEqual(self.run_command("--stop"), 0)
        self.assertEqual(len(self.events("webcam-start")), len(self.events("webcam-exit")), "Stop returned before webcam cleanup")
        self.run_command("--webcam")
        self.wait_for(lambda: sum("Recording started" in " ".join(event["args"]) for event in self.notifications()) == 2, "Immediate restart was lost during cleanup")
        self.assertEqual(self.run_command("--stop"), 0)
        self.assert_children_stopped()

    def test_concurrent_toggles_never_duplicate_recorders(self):
        processes = [self.launch() for _ in range(4)]
        for process in processes:
            process.wait(timeout=10)
        self.wait_for(lambda: bool(self.events("recorder-start")), "No recorder was launched")
        self.run_command("--stop")
        self.assert_children_stopped()
        active = set()
        starts = 0
        for event in self.events():
            if event["event"] == "recorder-start":
                starts += 1
                active.add(event["pid"])
                self.assertLessEqual(len(active), 1, "Concurrent recorders were launched")
            elif event["event"] == "recorder-exit":
                active.discard(event["pid"])
        self.assertGreater(starts, 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
