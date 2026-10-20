{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gpu-screen-recorder
    pkgs.ffmpeg
    pkgs.v4l-utils
    pkgs.jq
    pkgs.gawk
    pkgs.libnotify
    pkgs.coreutils
    pkgs.util-linux
    pkgs.hyprland
  ];
in
writeShellScriptBin "prism-screenrecord" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  DESKTOP_AUDIO="false"
  MICROPHONE_AUDIO="false"
  WEBCAM="false"
  WEBCAM_DEVICE=""
  STOP_ACTION="false"

  show_help() {
    echo "Prism Screen Recorder"
    echo "Usage: prism-screenrecord [options]"
    echo ""
    echo "Options:"
    echo "  --desktop      Include system audio"
    echo "  --mic          Include microphone audio"
    echo "  --webcam       Include a webcam overlay"
    echo "  --device=PATH  Specify webcam device (e.g. /dev/video0)"
    echo "  --stop         Stop this recording and save it"
    echo "  --help         Show this message"
  }

  for arg in "$@"; do
    case "$arg" in
      --desktop)  DESKTOP_AUDIO="true" ;;
      --mic)      MICROPHONE_AUDIO="true" ;;
      --webcam)   WEBCAM="true" ;;
      --device=*) WEBCAM_DEVICE="''${arg#*=}" ;;
      --stop)     STOP_ACTION="true" ;;
      --help)     show_help; exit 0 ;;
      *)          echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
  done

  notify() {
    notify-send "Prism Recorder" "$@" || true
  }

  if [[ -z "''${XDG_RUNTIME_DIR:-}" ]]; then
    notify "Cannot record: XDG_RUNTIME_DIR is not set." -u critical
    exit 1
  fi
  umask 077
  STATE_DIR="$XDG_RUNTIME_DIR/prism-screenrecord"
  LOG_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/prism"
  LOG_FILE="$LOG_DIR/screenrecord.log"
  SOCKET="$STATE_DIR/recorder.sock"
  mkdir -p "$STATE_DIR" "$LOG_DIR" || exit 1

  # Serialize shortcuts; the supervisor holds a separate lock for its lifetime.
  exec 9>"$STATE_DIR/command.lock" || exit 1
  if $STOP_ACTION; then
    flock 9 || exit 1
  else
    flock -n 9 || exit 0
  fi
  exec 8>"$STATE_DIR/session.lock" || exit 1
  if ! flock -n 8; then
    if [[ ! -e "$STATE_DIR/ready" ]]; then
      if read -r recorder_pid < "$STATE_DIR/recorder.pid"; then
        touch "$STATE_DIR/stopping"
        kill -INT "$recorder_pid" 2>/dev/null
        for _ in {1..20}; do
          if ! kill -0 "$recorder_pid" 2>/dev/null; then
            notify "Recording cancelled."
            flock -u 9
            flock 8
            exit 0
          fi
          sleep 0.1
        done
        rm -f "$STATE_DIR/stopping"
        notify "Could not cancel capture yet. Cancel the screen-sharing picker or try stopping again. See $LOG_FILE" -u critical
        exit 1
      fi
    else
      touch "$STATE_DIR/stopping"
      if saved_file=$(timeout 30s gsr-cli -ipc "$SOCKET" stop 2>>"$LOG_FILE"); then
        if [[ -s "$saved_file" ]] && ffprobe -v error "$saved_file" >>"$LOG_FILE" 2>&1; then
          notify "Recording saved: $saved_file" -i media-playback-stop
        else
          notify "Could not verify the saved video. See $LOG_FILE" -u critical
          flock -u 9
          flock 8
          exit 1
        fi
      else
        rm -f "$STATE_DIR/stopping"
        notify "Save failed or timed out; the recorder may still be running. See $LOG_FILE" -u critical
        exit 1
      fi
    fi
    # Cleanup needs the command lock; release it before waiting for the supervisor.
    flock -u 9
    flock 8
    exit 0
  fi
  $STOP_ACTION && exit 0

  if [[ -f ~/.config/user-dirs.dirs ]]; then
    # shellcheck source=/dev/null
    source ~/.config/user-dirs.dirs
  fi
  OUTPUT_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"
  if ! mkdir -p "$OUTPUT_DIR"; then
    notify "Cannot create recording directory: $OUTPUT_DIR" -u critical
    exit 1
  fi
  if ! : > "$LOG_FILE"; then
    notify "Cannot write recording log: $LOG_FILE" -u critical
    exit 1
  fi

  start_webcam_overlay() {
    if [[ -z "$WEBCAM_DEVICE" ]]; then
      WEBCAM_DEVICE=$(v4l2-ctl --list-devices 2>/dev/null | awk '/^[[:space:]]*\/dev\/video/ {print $1; exit}')
      [[ -z "$WEBCAM_DEVICE" ]] && {
        notify "No webcam detected. Recording will continue without it." -u critical
        return 1
      }
    fi

    local scale target_width formats res
    scale=$(hyprctl monitors -j | jq -r '[.[] | select(.focused) | .scale][0] // 1') || scale=1
    target_width=$(awk -v scale="$scale" 'BEGIN {printf "%.0f", 360 * scale}')
    local preferred=("640x360" "1280x720" "1920x1080")
    local size_args=()
    formats=$(v4l2-ctl --list-formats-ext -d "$WEBCAM_DEVICE" 2>/dev/null)

    for res in "''${preferred[@]}"; do
      if [[ "$formats" == *"$res"* ]]; then
        size_args=(-video_size "$res")
        break
      fi
    done

    ffplay -f v4l2 "''${size_args[@]}" -framerate 30 "$WEBCAM_DEVICE" \
      -vf "scale=''${target_width}:-1" \
      -window_title "WebcamOverlay" \
      -noborder \
      -fflags nobuffer -flags low_delay \
      -probesize 32 -analyzeduration 0 \
      -loglevel error 8>&- 9>&- &
    webcam_pid=$!
  }

  (
    recorder_pid=""
    webcam_pid=""
    child_running() {
      local child_pid
      for child_pid in $(jobs -pr); do
        [[ "$child_pid" == "$1" ]] && return 0
      done
      return 1
    }
    # shellcheck disable=SC2329
    cleanup() {
      if [[ -n "$webcam_pid" ]]; then
        # An exited webcam's PID can be reused during a long recording.
        child_running "$webcam_pid" && kill "$webcam_pid" 2>/dev/null
        wait "$webcam_pid" 2>/dev/null
      fi
      flock 9
      rm -f "$SOCKET" "$STATE_DIR/recorder.pid" "$STATE_DIR/ready" "$STATE_DIR/stopping"
    }
    trap cleanup EXIT
    trap 'child_running "$recorder_pid" && kill -INT "$recorder_pid" 2>/dev/null; wait "$recorder_pid" 2>/dev/null; exit 1' HUP INT TERM
    rm -f "$SOCKET" "$STATE_DIR/ready" "$STATE_DIR/stopping"
    filename="$OUTPUT_DIR/Recording_$(date +'%Y-%m-%d_%H-%M-%S_%N').mp4"
    audio_args=()
    inputs=""
    $DESKTOP_AUDIO && inputs="default_output"
    if $MICROPHONE_AUDIO; then
      [[ -n "$inputs" ]] && inputs+="|"
      inputs+="default_input"
    fi
    [[ -n "$inputs" ]] && audio_args=(-a "$inputs")
    $WEBCAM && start_webcam_overlay

    # Background jobs inherit ignored SIGINT; restore it so pending capture can be cancelled.
    env --default-signal=INT gpu-screen-recorder -w portal -f 60 -o "$filename" \
      "''${audio_args[@]}" -ipc "$SOCKET" 8>&- 9>&- &
    recorder_pid=$!
    echo "$recorder_pid" > "$STATE_DIR/recorder.pid"
    notify "Select what to record in the screen-sharing picker." -i media-record
    flock -u 9

    while kill -0 "$recorder_pid" 2>/dev/null; do
      # A connected socket alone is not ready; this idempotent command waits for capture.
      if [[ -S "$SOCKET" ]] && gsr-cli -ipc "$SOCKET" set-paused false 8>&- 9>&-; then
        flock 9
        if [[ ! -e "$STATE_DIR/stopping" ]]; then
          touch "$STATE_DIR/ready"
          notify "Recording started. Saving to $OUTPUT_DIR" -i media-record
          if [[ -n "$webcam_pid" ]] && ! child_running "$webcam_pid"; then
            notify "Webcam preview failed. Recording continues without it. See $LOG_FILE" -u critical
          fi
        fi
        flock -u 9
        break
      fi
      sleep 0.1
    done

    wait "$recorder_pid"
    result=$?
    flock 9
    if [[ ! -e "$STATE_DIR/stopping" ]]; then
      if [[ $result -ne 0 ]]; then
        notify "Recording failed. See $LOG_FILE" -u critical
      elif [[ ! -e "$STATE_DIR/ready" ]]; then
        notify "Recording cancelled."
      elif [[ -s "$filename" ]] && ffprobe -v error "$filename"; then
        notify "Recording saved: $filename" -i media-playback-stop
      else
        notify "Could not verify the saved video. See $LOG_FILE" -u critical
      fi
    fi
  ) </dev/null >>"$LOG_FILE" 2>&1 &
  disown
''
