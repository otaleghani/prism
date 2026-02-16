{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.jq
    pkgs.gum
  ];
in
writeShellScriptBin "prism-save" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  TRACKFILE="$HOME/.prismsave"
  CURRENT_USER=$(whoami)

  # Terminal auto-launch
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        exec prism-tui "$0" "$@"
    fi
  fi

  # Header display
  clear
  gum style --border double --margin "1 2" --padding "1 2" --foreground 4 "Prism State Saver"

  # Repo location setup
  if [ -d "/etc/prism" ]; then
      REPO_DIR="/etc/prism"
  elif [ -d "$HOME/.config/prism" ]; then
      REPO_DIR="$HOME/.config/prism"
  else
      gum style --foreground 1 "Error: Prism repository not found."
      exit 1
  fi

  OVERRIDES_DIR="$REPO_DIR/overrides/$CURRENT_USER"

  # Relative path calculation
  get_paths() {
      local TARGET="$1"
      ABS_FILE=$(realpath "$TARGET")
      HOME_DIR=$(realpath "$HOME")

      if [[ "$ABS_FILE" != "$HOME_DIR"* ]]; then
          gum style --foreground 1 "Error: '$TARGET' is not inside home directory."
          return 1
      fi

      REL_PATH="''${ABS_FILE#$HOME_DIR/}"
      DEST_PATH="$OVERRIDES_DIR/$REL_PATH"
      DEST_DIR=$(dirname "$DEST_PATH")
      return 0
  }

  # File synchronization logic
  sync_path() {
      get_paths "$1" || return
      
      [ ! -d "$DEST_DIR" ] && mkdir -p "$DEST_DIR"
      [ -e "$DEST_PATH" ] && rm -rf "$DEST_PATH"

      cp -r "$ABS_FILE" "$DEST_PATH"
      echo "  [Synced] -> $REL_PATH"
  }

  COMMAND="$1"
  ARG="$2"

  case "$COMMAND" in
    "delete"|"remove")
        [ -z "$ARG" ] && { echo "Usage: prism-save delete <file>"; exit 1; }
        
        get_paths "$ARG" || exit 1
        echo "Removing override for: $REL_PATH"
        
        # Repository cleanup
        if [ -e "$DEST_PATH" ]; then
            rm -rf "$DEST_PATH"
            echo "  [Deleted] -> Removed from repo overrides"
            rmdir -p "$DEST_DIR" 2>/dev/null || true
        else
            echo "  [Notice] -> File not found in repo (skipping)"
        fi
        
        # Tracking removal
        if [ -f "$TRACKFILE" ]; then
            grep -vFx "$ABS_FILE" "$TRACKFILE" > "$TRACKFILE.tmp"
            mv "$TRACKFILE.tmp" "$TRACKFILE"
            echo "  [Untracked] -> Removed from global tracking list"
        fi
        ;;

    "sync"|"")
        echo "Synchronizing tracked files to overrides/$CURRENT_USER/..."
        
        if [ ! -f "$TRACKFILE" ]; then
            echo "No tracking file found. Run 'prism-save <file>' to begin."
        else
            while IFS= read -r line; do
                [[ -z "$line" || "$line" =~ ^# ]] && continue
                EXPANDED_PATH="''${line/#\~/$HOME}"
                
                if [ -e "$EXPANDED_PATH" ]; then
                    sync_path "$EXPANDED_PATH"
                else
                    gum style --foreground 3 "  [Warning] -> Tracked file missing: $line"
                fi
            done < "$TRACKFILE"
        fi
        ;;

    *)
        # Default file save
        TARGET_FILE="$1"
        [ ! -e "$TARGET_FILE" ] && { gum style --foreground 1 "Error: File missing."; exit 1; }

        sync_path "$TARGET_FILE"

        # Tracking update
        ABS_TARGET=$(realpath "$TARGET_FILE")
        touch "$TRACKFILE"
        
        if ! grep -Fxq "$ABS_TARGET" "$TRACKFILE"; then
            echo "$ABS_TARGET" >> "$TRACKFILE"
            echo "  [Tracked] -> Added to permanent list"
        else
            echo "  [Notice] -> Already being tracked"
        fi
        ;;
  esac

  # Exit handling
  echo ""
  gum style --foreground 4 "Operation complete. Press any key to exit..."
  read -n 1 -s
''
