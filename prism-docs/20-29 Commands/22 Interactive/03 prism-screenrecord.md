# `prism-screenrecord`

A screen recording utility for Prism and [[01 Hyprland]], using `gpu-screen-recorder` at 60 FPS with optional desktop audio, microphone audio, and a webcam preview.

## How it works

1. **Select a source:** The Wayland screen-sharing portal asks what to capture. Available sources depend on the portal. The initial selection prompt does not mean capture has started.
2. **Confirm capture:** A "Recording started" notification appears after the recorder confirms it is ready. Cancelling the picker or a startup failure does not produce a success notification.
3. **Optional audio and webcam:** Desktop and microphone audio are mixed when both are requested. `ffplay` opens a floating window titled "WebcamOverlay"; include that window in the area you capture to record it. If the webcam is unavailable, screen recording continues with a warning.
4. **Stop and save:** Running the command again stops the current recording. The saved notification includes its filename after the recorder confirms saving and the file passes a basic media check. The webcam closes when recording ends, including on failure.

Only one Prism recording runs per user. Overlapping toggle shortcuts are ignored while another start or stop command is being handled; an explicit `--stop` waits for that command. Other recording applications are not stopped.

## Dependencies

- `gpu-screen-recorder`: The recording engine and its bundled `gsr-cli` control tool.
- `ffmpeg`: `ffplay` for the webcam preview and `ffprobe` to check saved files.
- `v4l-utils`: For camera hardware detection.
- `hyprland`: To ensure window rules and scaling are handled correctly.
- `libnotify`: For start/stop status notifications.

## Usage

```bash
prism-screenrecord [options]
```

## Options

|**Flag**|**Description**|
|---|---|
|`--desktop`|Include system/desktop audio in the recording.|
|`--mic`|Include microphone audio in the recording.|
|`--webcam`|Open a webcam overlay window before starting.|
|`--device=/dev/videoX`|Manually specify which webcam device to use.|
|`--stop`|Stop the current Prism recording and save it; cancel a pending capture selection. Does nothing when idle.|
|`--help`|Show command usage.|

Without options, recording has no audio or webcam. Flags configure a new recording; running any start variant during an existing recording stops it instead of changing its settings. `--device` is used with `--webcam`.

## Shortcuts

|**Shortcut**|**Action**|
|---|---|
|`Super + O`|Toggle recording with desktop audio, microphone, and webcam.|
|`Super + Ctrl + O`|Stop and save, or cancel a pending capture selection.|

## Example: Streamer Mode

Record with desktop sound, your microphone, and your face on screen:

```bash
prism-screenrecord --desktop --mic --webcam
```

## Workflow & Integration

- **Output path:** Videos are saved to `~/Videos` (or your XDG Videos folder) with a timestamped filename, including fractional seconds to avoid overwriting a recent recording.
- **Window rules:** Prism matches the "WebcamOverlay" window title to keep the preview floating and pinned.
- **Tiling:** Focus the webcam preview and press `Super + Y` to toggle between floating and tiled. The preview remains resizable.
- **Webcam quality:** The preview captures the highest supported resolution up to 3840×2160 at approximately 30 FPS, preferring uncompressed NV12 when available at that resolution. It keeps full-resolution frames when you enlarge or tile it; only the initial window is small. Cameras without a recognized discrete 30 FPS mode use their defaults.
- **Desktop session:** The main Hyprland session starts and stops `hyprland-session.target`, which activates the graphical session required by the screen-sharing portal.

## Troubleshooting

Errors are kept in `${XDG_STATE_HOME:-~/.local/state}/prism/screenrecord.log`. This log is replaced on the next recording. Failed or partial video files are kept for inspection.

If the capture picker does not appear, check the desktop session and portal:

```bash
systemctl --user status graphical-session.target xdg-desktop-portal.service xdg-desktop-portal-hyprland.service
journalctl --user -b -u xdg-desktop-portal.service -u xdg-desktop-portal-hyprland.service
```

A save error leaves the recorder available for another stop attempt if it is still running. A slow or unresponsive save is reported after 30 seconds without force-killing the recorder.
