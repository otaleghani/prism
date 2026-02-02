{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gpu-screen-recorder
    pkgs.ffmpeg # For ffplay (webcam overlay)
    pkgs.v4l2-utils # For webcam detection
    pkgs.jq # JSON parsing (hyprctl)
    pkgs.gawk # Math
    pkgs.libnotify # Notifications
    pkgs.procps # pkill/pgrep
    pkgs.coreutils
    pkgs.hyprland # hyprctl
  ];
in
writeShellScriptBin "prism-screenrecord" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # --- Configuration ---
  # Detect XDG Videos directory or fallback to ~/Videos
  if [ -f ~/.config/user-dirs.dirs ]; then
    source ~/.config/user-dirs.dirs
  fi
  OUTPUT_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"

  if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
  fi

  # --- State Defaults ---
  DESKTOP_AUDIO="false"
  MICROPHONE_AUDIO="false"
  WEBCAM="false"
  WEBCAM_DEVICE=""
  STOP_ACTION="false"

  # --- Parse Arguments ---
  for arg in "$@"; do
    case "$arg" in
      --desktop)    DESKTOP_AUDIO="true" ;;
      --mic)        MICROPHONE_AUDIO="true" ;;
      --webcam)     WEBCAM="true" ;;
      --device=*)   WEBCAM_DEVICE="''${arg#*=}" ;;
      --stop)       STOP_ACTION="true" ;;
    esac
  done

  # --- Helper Functions ---

  cleanup_webcam() {
    pkill -f "WebcamOverlay" 2>/dev/null
  }

  start_webcam_overlay() {
    cleanup_webcam

    # 1. Auto-detect device if not specified
    if [[ -z "$WEBCAM_DEVICE" ]]; then
      # Find first /dev/video device provided by v4l2
      WEBCAM_DEVICE=$(v4l2-ctl --list-devices 2>/dev/null | grep -m1 "^\s*/dev/video" | tr -d '\t' | head -n 1)
      if [[ -z "$WEBCAM_DEVICE" ]]; then
        notify-send "Prism Recorder" "No webcam device found." -u critical
        return 1
      fi
    fi

    # 2. Scale Calculation (HiDPI support)
    # We query Hyprland for the scale of the focused monitor
    local scale=1
    if command -v hyprctl >/dev/null; then
       scale=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .scale')
    fi
    # Base width 360px * scale
    local target_width=$(awk "BEGIN {printf \"%.0f\", 360 * $scale}")

    # 3. Resolution Selection
    # Try to find a 16:9 resolution supported by the camera
    local preferred=("640x360" "1280x720" "1920x1080")
    local size_arg=""
    local formats=$(v4l2-ctl --list-formats-ext -d "$WEBCAM_DEVICE" 2>/dev/null)

    for res in "''${preferred[@]}"; do
      if echo "$formats" | grep -q "$res"; then
        size_arg="-video_size $res"
        break
      fi
    done

    # 4. Launch ffplay as the overlay
    # -noborder: Frameless
    # -window_title: Used for window rules (float/pin)
    ffplay -f v4l2 $size_arg -framerate 30 "$WEBCAM_DEVICE" \
      -vf "scale=''${target_width}:-1" \
      -window_title "WebcamOverlay" \
      -noborder \
      -fflags nobuffer -flags low_delay \
      -probesize 32 -analyzeduration 0 \
      -loglevel quiet &
      
    sleep 1
  }

  start_recording() {
    local timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
    local filename="$OUTPUT_DIR/Recording_$timestamp.mp4"
    local audio_args=""
    local inputs=""

    # gpu-screen-recorder audio syntax: -a "device1|device2"
    if [[ "$DESKTOP_AUDIO" == "true" ]]; then
        inputs+="default_output"
    fi
    
    if [[ "$MICROPHONE_AUDIO" == "true" ]]; then
        if [[ -n "$inputs" ]]; then inputs+="|"; fi
        inputs+="default_input"
    fi

    if [[ -n "$inputs" ]]; then
        audio_args="-a $inputs"
    fi

    echo "[Prism] Starting recording..."
    
    # Start Recorder
    # -w portal: Use xdg-desktop-portal (Native Wayland selection)
    # -f 60: 60 FPS
    gpu-screen-recorder -w portal -f 60 -o "$filename" $audio_args &
    
    notify-send "Recording Started" "Saving to Videos/..." -i media-record
    
    # Signal Waybar to show recording icon (requires custom module config)
    pkill -RTMIN+8 waybar 2>/dev/null
  }

  stop_recording() {
    # Send SIGINT to allow graceful saving of MP4
    pkill -SIGINT -f "^gpu-screen-recorder"

    # Wait loop (max 5 seconds)
    local count=0
    while pgrep -f "^gpu-screen-recorder" >/dev/null && [ $count -lt 50 ]; do
      sleep 0.1
      count=$((count + 1))
    done

    # Force kill if stuck
    if pgrep -f "^gpu-screen-recorder" >/dev/null; then
      pkill -9 -f "^gpu-screen-recorder"
      notify-send "Prism Recorder" "Error: Recording force-killed. File may be corrupt." -u critical
    else
      notify-send "Prism Recorder" "Recording Saved." -i media-playback-stop
    fi
    
    cleanup_webcam
    pkill -RTMIN+8 waybar 2>/dev/null
  }

  # --- Main Logic (Toggle) ---

  IS_RECORDING=false
  if pgrep -f "^gpu-screen-recorder" >/dev/null; then IS_RECORDING=true; fi

  IS_WEBCAM=false
  if pgrep -f "WebcamOverlay" >/dev/null; then IS_WEBCAM=true; fi

  # 1. Force Stop
  if [[ "$STOP_ACTION" == "true" ]]; then
     if $IS_RECORDING; then stop_recording; fi
     cleanup_webcam
     exit 0
  fi

  # 2. Toggle Logic
  if $IS_RECORDING; then
     # If recording, stop everything
     stop_recording
  elif $IS_WEBCAM && [[ "$WEBCAM" != "true" ]]; then
     # If only webcam is open (preview mode) and we didn't ask to record, just close it
     cleanup_webcam
  else
     # Start Recording
     if [[ "$WEBCAM" == "true" ]]; then start_webcam_overlay; fi
     start_recording
  fi
''
