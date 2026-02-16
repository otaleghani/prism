{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.grim
    pkgs.slurp
    pkgs.wayfreeze
    pkgs.satty
    pkgs.jq
    pkgs.wl-clipboard
    pkgs.libnotify
    pkgs.procps
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-screenshot" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Directory resolution
  # Detects XDG pictures directory for automatic storage
  if [ -f ~/.config/user-dirs.dirs ]; then
    source ~/.config/user-dirs.dirs
  fi
  OUTPUT_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}"
  mkdir -p "$OUTPUT_DIR"

  # Toggle behavior
  # Terminates existing slurp processes if triggered twice
  if pkill -0 slurp 2>/dev/null; then
    pkill slurp
    exit 0
  fi

  MODE="''${1:-smart}"
  PROCESSING="''${2:-edit}"

  # Geometry calculation
  # Maps active workspace monitors and windows to XKB-compatible rectangles
  get_rectangles() {
    local active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
    
    # Monitor geometry
    hyprctl monitors -j | jq -r --arg ws "$active_workspace" '.[] | select(.activeWorkspace.id == ($ws | tonumber)) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'
    
    # Window geometry
    hyprctl clients -j | jq -r --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
  }

  # Selection logic
  case "$MODE" in
    region)
      # Manual area selection
      wayfreeze & PID=$! ; sleep 0.1
      SELECTION=$(slurp 2>/dev/null)
      kill $PID 2>/dev/null
      ;;
      
    windows)
      # Automated window snapping
      wayfreeze & PID=$! ; sleep 0.1
      SELECTION=$(get_rectangles | slurp -r 2>/dev/null)
      kill $PID 2>/dev/null
      ;;
      
    fullscreen)
      # Immediate monitor capture
      SELECTION=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"')
      ;;
      
    smart|*)
      # Smart heuristic: drag for region, click for window
      RECTS=$(get_rectangles)
      wayfreeze & PID=$! ; sleep 0.1
      SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)
      kill $PID 2>/dev/null

      # Logic: detect tiny selection areas as targeted window clicks
      if [[ "$SELECTION" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
        sel_w="''${BASH_REMATCH[3]}"
        sel_h="''${BASH_REMATCH[4]}"
        
        if (( sel_w * sel_h < 20 )); then
          click_x="''${BASH_REMATCH[1]}"
          click_y="''${BASH_REMATCH[2]}"

          while IFS= read -r rect; do
            if [[ "$rect" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+) ]]; then
              rx="''${BASH_REMATCH[1]}" ; ry="''${BASH_REMATCH[2]}"
              rw="''${BASH_REMATCH[3]}" ; rh="''${BASH_REMATCH[4]}"

              if (( click_x >= rx && click_x < rx+rw && click_y >= ry && click_y < ry+rh )); then
                SELECTION="''${rx},''${ry} ''${rw}x''${rh}"
                break
              fi
            fi
          done <<< "$RECTS"
        fi
      fi
      ;;
  esac

  [ -z "$SELECTION" ] && exit 0

  # Post-processing logic
  # Handles direct clipboard copying or interactive annotation
  FILENAME="$OUTPUT_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

  if [[ "$PROCESSING" == "copy" ]]; then
    grim -g "$SELECTION" - | wl-copy || {
      notify-send "Prism Screenshot" "Failed to capture or copy image." -u critical
      exit 1
    }
    notify-send "Prism Screenshot" "Image copied to clipboard." -i camera-photo
  else
    # Invokes Satty for annotation and local storage
    grim -g "$SELECTION" - | \
      satty --filename - \
            --output-filename "$FILENAME" \
            --early-exit \
            --actions-on-enter save-to-clipboard \
            --save-after-copy \
            --copy-command 'wl-copy' || {
      notify-send "Prism Screenshot" "Screenshot engine or editor crashed." -u critical
      exit 1
    }
    notify-send "Prism Screenshot" "Capture saved and copied." -i camera-photo
  fi
''
