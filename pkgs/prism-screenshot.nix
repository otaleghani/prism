{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.grim # Grab image
    pkgs.slurp # Select region
    pkgs.wayfreeze # Freeze screen for stable selection
    pkgs.satty # Annotation tool
    pkgs.jq # Parse Hyprland JSON
    pkgs.wl-clipboard # Copy to clipboard
    pkgs.libnotify # Notifications
    pkgs.procps # pkill
    pkgs.coreutils # date, sleep, etc.
  ];
in
writeShellScriptBin "prism-screenshot" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Usage: prism-screenshot [mode] [processing]
  # Modes: smart (default), region, windows, fullscreen
  # Processing: edit (default/satty), copy (no edit)

  # Setup Output Directory
  if [ -f ~/.config/user-dirs.dirs ]; then
    source ~/.config/user-dirs.dirs
  fi
  # Use XDG_PICTURES_DIR or fallback to ~/Pictures
  OUTPUT_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}"

  if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
  fi

  # Toggle Behavior
  # If slurp is already running (user changed mind), kill it and exit
  if pgrep slurp >/dev/null; then
    pkill slurp
    exit 0
  fi

  MODE="''${1:-smart}"
  PROCESSING="''${2:-edit}"

  # Helper: Get geometry of all windows and monitors on current workspace
  get_rectangles() {
    # Get active workspace ID
    local active_workspace=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')
    
    # Get Monitor Geometry (x,y wxh)
    hyprctl monitors -j | jq -r --arg ws "$active_workspace" '.[] | select(.activeWorkspace.id == ($ws | tonumber)) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"'
    
    # Get Window Geometry (at[0],at[1] size[0]xsize[1])
    hyprctl clients -j | jq -r --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
  }

  echo "[Prism] Starting Screenshot (Mode: $MODE)"

  # Selection logic
  case "$MODE" in
    region)
      # Freeze -> Select -> Unfreeze
      wayfreeze & PID=$!
      sleep 0.1
      SELECTION=$(slurp 2>/dev/null)
      kill $PID 2>/dev/null
      ;;
      
    windows)
      # Snaps specifically to windows
      wayfreeze & PID=$!
      sleep 0.1
      SELECTION=$(get_rectangles | slurp -r 2>/dev/null)
      kill $PID 2>/dev/null
      ;;
      
    fullscreen)
      # Automatically selects the current monitor
      SELECTION=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x),\(.y) \((.width / .scale) | floor)x\((.height / .scale) | floor)"')
      ;;
      
    smart|*)
      # The Logic:
      # 1. Gather all window/monitor rectangles
      # 2. Let user drag (slurp)
      # 3. If the user just CLICKED (selection area < 20px), assume they wanted to click a window.
      # 4. Find which pre-calculated rectangle contains the click.
      
      RECTS=$(get_rectangles)
      wayfreeze & PID=$!
      sleep 0.1
      SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)
      kill $PID 2>/dev/null

      # Heuristic: Check if selection is a tiny "click" (less than 20 pixels area)
      # Regex matches: X,Y WxH
      if [[ "$SELECTION" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
        # Capture regex groups
        sel_w="''${BASH_REMATCH[3]}"
        sel_h="''${BASH_REMATCH[4]}"
        
        if (( sel_w * sel_h < 20 )); then
          echo "[Prism] Smart Click detected. snapping to window..."
          click_x="''${BASH_REMATCH[1]}"
          click_y="''${BASH_REMATCH[2]}"

          # Loop through RECTS to find what was clicked
          while IFS= read -r rect; do
            if [[ "$rect" =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+) ]]; then
              rx="''${BASH_REMATCH[1]}"
              ry="''${BASH_REMATCH[2]}"
              rw="''${BASH_REMATCH[3]}"
              rh="''${BASH_REMATCH[4]}"

              # Check collision
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

  if [ -z "$SELECTION" ]; then
    echo "[Prism] No selection made."
    exit 0
  fi

  # Processing
  FILENAME="$OUTPUT_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

  if [[ "$PROCESSING" == "copy" ]]; then
    # Raw copy to clipboard
    grim -g "$SELECTION" - | wl-copy
    notify-send "Screenshot Copied" "Region saved to clipboard" -i camera-photo
  else
    # Edit in Satty (Annotation tool)
    # Satty features:
    # --early-exit: Close immediately after saving/copying
    # --copy-command: What to use for copying
    # --save-after-copy: Auto-save file even if user just hit Ctrl+C
    grim -g "$SELECTION" - | \
      satty --filename - \
            --output-filename "$FILENAME" \
            --early-exit \
            --actions-on-enter save-to-clipboard \
            --save-after-copy \
            --copy-command 'wl-copy'
  fi
''
