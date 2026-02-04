{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.jq
  ];
in
writeShellScriptBin "prism-save" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Usage: 
  #   prism-save <file>         -> Track file and save it
  #   prism-save                -> Save all tracked files (Sync)
  #   prism-save delete <file>  -> Remove from overrides and stop tracking

  TRACKFILE="$HOME/.prismsave"
  CURRENT_USER=$(whoami)

  # --- 1. SETUP REPO LOCATION ---
  if [ -d "/etc/prism" ]; then
      REPO_DIR="/etc/prism"
  elif [ -d "$HOME/.config/prism" ]; then
      REPO_DIR="$HOME/.config/prism"
  else
      echo "Error: Prism repository not found at /etc/prism or ~/.config/prism"
      exit 1
  fi

  OVERRIDES_DIR="$REPO_DIR/overrides/$CURRENT_USER"

  # --- HELPER: PATH RESOLUTION ---
  get_paths() {
      local TARGET="$1"
      ABS_FILE=$(realpath "$TARGET")
      HOME_DIR=$(realpath "$HOME")

      if [[ "$ABS_FILE" != "$HOME_DIR"* ]]; then
          echo "Error: '$TARGET' is not inside your home directory."
          return 1
      fi

      # Calculate Relative Path (e.g., .config/nvim)
      # Nix escaping: ''${var} prevents Nix from interpreting it
      REL_PATH="''${ABS_FILE#$HOME_DIR/}"
      DEST_PATH="$OVERRIDES_DIR/$REL_PATH"
      DEST_DIR=$(dirname "$DEST_PATH")
      return 0
  }

  # --- HELPER: SYNC FUNCTION ---
  sync_path() {
      get_paths "$1" || return
      
      if [ ! -d "$DEST_DIR" ]; then
          mkdir -p "$DEST_DIR"
      fi

      if [ -e "$DEST_PATH" ]; then
          rm -rf "$DEST_PATH"
      fi

      cp -r "$ABS_FILE" "$DEST_PATH"
      echo "  -> Synced: $REL_PATH"
  }

  # --- MAIN LOGIC ---
  COMMAND="$1"
  ARG="$2"

  case "$COMMAND" in
    "delete"|"remove")
        if [ -z "$ARG" ]; then
            echo "Usage: prism-save delete <file>"
            exit 1
        fi
        
        get_paths "$ARG" || exit 1
        
        echo "Removing override for: $REL_PATH"
        
        # 1. Remove from Repo Overrides
        if [ -e "$DEST_PATH" ]; then
            rm -rf "$DEST_PATH"
            echo "  - Deleted from repo: $DEST_PATH"
            
            # Clean up empty parent directories in repo
            rmdir -p "$DEST_DIR" 2>/dev/null || true
        else
            echo "  ! File not found in repo overrides (skipping)"
        fi
        
        # 2. Remove from Tracking File
        if [ -f "$TRACKFILE" ]; then
            # grep -vFx: Invert match, Fixed string (no regex), Line match
            grep -vFx "$ABS_FILE" "$TRACKFILE" > "$TRACKFILE.tmp"
            mv "$TRACKFILE.tmp" "$TRACKFILE"
            echo "  - Removed from tracking list"
        fi
        
        echo "✅ Cleanup Complete. (Local file in Home was NOT deleted)"
        ;;

    "sync"|"")
        echo "Saving tracked files to overrides/$CURRENT_USER/..."
        
        if [ ! -f "$TRACKFILE" ]; then
            echo "No tracking file found ($TRACKFILE)."
            echo "Run 'prism-save <file>' to start tracking a file."
            exit 0
        fi

        while IFS= read -r line; do
            # Skip empty lines or comments
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            
            # Expand tilde manually
            EXPANDED_PATH="''${line/#\~/$HOME}"
            
            if [ -e "$EXPANDED_PATH" ]; then
                sync_path "$EXPANDED_PATH"
            else
                echo "  x Warning: Tracked file not found: $line"
            fi
        done < "$TRACKFILE"
        
        echo "✅ Sync Complete."
        ;;

    *)
        # Default: Treat $1 as a file to save
        TARGET_FILE="$1"
        
        if [ ! -e "$TARGET_FILE" ]; then
            echo "Error: File '$TARGET_FILE' does not exist."
            echo "Usage: prism-save <file> OR prism-save delete <file>"
            exit 1
        fi

        # 1. Save it immediately
        sync_path "$TARGET_FILE"

        # 2. Add to tracking list
        ABS_TARGET=$(realpath "$TARGET_FILE")
        touch "$TRACKFILE"
        
        if ! grep -Fxq "$ABS_TARGET" "$TRACKFILE"; then
            echo "$ABS_TARGET" >> "$TRACKFILE"
            echo "➕ Added to tracking list ($TRACKFILE)"
        else
            echo "ℹ️  Already tracked."
        fi
        ;;
  esac
''
