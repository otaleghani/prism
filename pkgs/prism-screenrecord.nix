{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gpu-screen-recorder
    pkgs.ffmpeg
    pkgs.v4l-utils
    pkgs.jq
    pkgs.gawk
    pkgs.libnotify
    pkgs.procps
    pkgs.coreutils
    pkgs.hyprland
  ];
in
writeShellScriptBin "prism-screenrecord" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Directory resolution
  # Detects XDG user directories to ensure recordings land in the correct folder
  if [ -f ~/.config/user-dirs.dirs ]; then
    source ~/.config/user-dirs.dirs
  fi
  OUTPUT_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"
  mkdir -p "$OUTPUT_DIR"

  # State defaults
  DESKTOP_AUDIO="false"
  MICROPHONE_AUDIO="false"
  WEBCAM="false"
  WEBCAM_DEVICE=""
  STOP_ACTION="false"

  # Usage documentation
  show_help() {
    echo "Prism Screen Recorder"
    echo "Usage: prism-screenrecord [options]"
    echo ""
    echo "Options:"
    echo "  --desktop      Include system audio"
    echo "  --mic          Include microphone audio"
    echo "  --webcam       Toggle webcam overlay"
    echo "  --device=PATH  Specify webcam device (e.g. /dev/video0)"
    echo "  --stop         Force stop all recording processes"
    echo "  --help         Show this message"
  }

  # Argument parsing
  for arg in "$@"; do
    case "$arg" in
      --desktop)  DESKTOP_AUDIO="true" ;;
      --mic)      MICROPHONE_AUDIO="true" ;;
      --webcam)   WEBCAM="true" ;;
      --device=*) WEBCAM_DEVICE="''${arg#*=}" ;;
      --stop)     STOP_ACTION="true" ;;
      --help)     show_help; exit 0 ;;
    esac
  done

  # Helper: Webcam cleanup
  cleanup_webcam() {
    pkill -f "WebcamOverlay" 2>/dev/null
  }

  # Helper: Webcam initialization
  # Calculates HiDPI scaling and selects optimal 16:9 resolution
  start_webcam_overlay() {
    cleanup_webcam

    if [[ -z "$WEBCAM_DEVICE" ]]; then
      WEBCAM_DEVICE=$(v4l2-ctl --list-devices 2>/dev/null | grep -m1 "^\s*/dev/video" | tr -d '\t' | head -n 1)
      [[ -z "$WEBCAM_DEVICE" ]] && {
        notify-send "Prism Recorder" "Error: No webcam detected." -u critical
        return 1
      }
    fi

    local scale=1
    if command -v hyprctl >/dev/null; then
        scale=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .scale')
    fi
    local target_width=$(awk "BEGIN {printf \"%.0f\", 360 * $scale}")

    local preferred=("640x360" "1280x720" "1920x1080")
    local size_arg=""
    local formats=$(v4l2-ctl --list-formats-ext -d "$WEBCAM_DEVICE" 2>/dev/null)

    for res in "''${preferred[@]}"; do
      if echo "$formats" | grep -q "$res"; then
        size_arg="-video_size $res"
        break
      fi
    done

    ffplay -f v4l2 $size_arg -framerate 30 "$WEBCAM_DEVICE" \
      -vf "scale=''${target_width}:-1" \
      -window_title "WebcamOverlay" \
      -noborder \
      -fflags nobuffer -flags low_delay \
      -probesize 32 -analyzeduration 0 \
      -loglevel quiet &
  }

  # Helper: Start process
  # Invokes gpu-screen-recorder with Wayland portal for window selection
  start_recording() {
    local timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
    local filename="$OUTPUT_DIR/Recording_$timestamp.mp4"
    local audio_args=""
    local inputs=""

    [[ "$DESKTOP_AUDIO" == "true" ]] && inputs+="default_output"
    if [[ "$MICROPHONE_AUDIO" == "true" ]]; then
        [[ -n "$inputs" ]] && inputs+="|"
        inputs+="default_input"
    fi
    [[ -n "$inputs" ]] && audio_args="-a $inputs"

    gpu-screen-recorder -w portal -f 60 -o "$filename" $audio_args & || {
        notify-send "Prism Recorder" "Failed to start recording engine." -u critical
        exit 1
    }
    
    notify-send "Prism Recorder" "Recording started. Saving to $OUTPUT_DIR" -i media-record
    pkill -RTMIN+8 waybar 2>/dev/null
  }

  # Helper: Stop process
  # Gracefully terminates recording to prevent file corruption
  stop_recording() {
    pkill -SIGINT -f "gpu-screen-recorder"

    local count=0
    while pgrep -f "^gpu-screen-recorder" >/dev/null && [ $count -lt 50 ]; do
      sleep 0.1
      count=$((count + 1))
    done

    if pgrep -f "^gpu-screen-recorder" >/dev/null; then
      pkill -9 -f "^gpu-screen-recorder"
      notify-send "Prism Recorder" "Process force-killed. Check video integrity." -u critical
    else
      notify-send "Prism Recorder" "Recording saved successfully." -i media-playback-stop
    fi
    
    cleanup_webcam
    pkill -RTMIN+8 waybar 2>/dev/null
  }

  # Main execution logic
  IS_RECORDING=false
  pgrep -f "^gpu-screen-recorder" >/dev/null && IS_RECORDING=true

  IS_WEBCAM=false
  pgrep -f "WebcamOverlay" >/dev/null && IS_WEBCAM=true

  # Force stop handler
  if [[ "$STOP_ACTION" == "true" ]]; then
     $IS_RECORDING && stop_recording
     cleanup_webcam
     exit 0
  fi

  # Toggle handler
  if $IS_RECORDING; then
     stop_recording
  elif $IS_WEBCAM && [[ "$WEBCAM" != "true" ]]; then
     cleanup_webcam
  else
     [[ "$WEBCAM" == "true" ]] && start_webcam_overlay
     start_recording
  fi
''
