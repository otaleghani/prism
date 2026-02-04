{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.swww
    pkgs.fzf
    pkgs.findutils # for find
    pkgs.coreutils # for sort, head
  ];

in
writeShellScriptBin "prism-wall" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # --- CONFIGURATION ---
  BASE_DIR="$HOME/.local/share/prism"
  CURRENT_LINK="$BASE_DIR/current"

  # Locations to search
  THEME_WALL_DIR="$CURRENT_LINK/wall"
  CUSTOM_WALL_DIR="$BASE_DIR/wallpapers"

  cmd="$1"

  # Helper function to gather all wallpapers from both sources
  get_wallpapers() {
    # Check Theme Directory
    if [ -d "$THEME_WALL_DIR" ]; then
        find "$THEME_WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \)
    fi
    
    # Check Custom Directory
    if [ -d "$CUSTOM_WALL_DIR" ]; then
        find "$CUSTOM_WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \)
    fi
  }

  # Ensure swww is running
  if ! pgrep swww-daemon > /dev/null; then
    swww-daemon >/dev/null 2>&1 &
    sleep 0.5
  fi

  case "$cmd" in
    "next"|"random"|*)
      # Pick random from combined list
      # sort -R shuffles the lines
      IMAGE=$(get_wallpapers | sort -R | head -n 1)
      ;;
      
    "select")
      # Interactive fzf selection
      # We display the full path so you know if it's a theme or custom wallpaper
      IMAGE=$(get_wallpapers | fzf --prompt="Wallpaper> " --preview "echo {}" --layout=reverse --border --height=40%)
      ;;
  esac

  if [ -n "$IMAGE" ]; then
    echo "[Prism] Setting wallpaper: $IMAGE"
    swww img "$IMAGE" \
      --transition-type grow \
      --transition-pos 0.5,0.5 \
      --transition-fps 60 \
      --transition-step 90 \
      > /dev/null 2>&1 &
  else
    echo "No wallpapers found in:"
    echo "  - $THEME_WALL_DIR"
    echo "  - $CUSTOM_WALL_DIR"
  fi
''
