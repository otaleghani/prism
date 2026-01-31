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
  # Defined in Bash because $HOME is a runtime variable
  BASE_DIR="$HOME/.local/share/prism"
  CURRENT_LINK="$BASE_DIR/current"
  WALL_DIR="$CURRENT_LINK/wall"

  cmd="$1"

  if [ ! -d "$WALL_DIR" ]; then
    echo "Error: No 'wall' directory found in current theme ($WALL_DIR)."
    exit 1
  fi

  # Ensure swww is running
  if ! pgrep swww-daemon > /dev/null; then
    swww-daemon &
    sleep 0.5
  fi

  case "$cmd" in
    "next")
      # Simple 'next' logic: picks a random one for now
      IMAGE=$(find "$WALL_DIR" -type f | sort -R | head -n 1)
      ;;
    "select")
      # Interactive fzf
      IMAGE=$(find "$WALL_DIR" -type f -printf "%P\n" | fzf --prompt="Wallpaper> " --preview "echo {}" --layout=reverse --border --height=40%)
      if [ -n "$IMAGE" ]; then
        IMAGE="$WALL_DIR/$IMAGE"
      fi
      ;;
    "random"|*)
      # Default: Random
      IMAGE=$(find "$WALL_DIR" -type f | sort -R | head -n 1)
      ;;
  esac

  if [ -n "$IMAGE" ]; then
    echo "[Prism] Setting wallpaper: $IMAGE"
    swww img "$IMAGE" --transition-type grow --transition-pos 0.5,0.5 --transition-fps 60 --transition-step 90
  fi
''
