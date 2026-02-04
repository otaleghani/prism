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
  #   prism-save <file>   -> Track file and save it
  #   prism-save          -> Save all tracked files (Sync)

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

  # FIX: Save to overrides/<username>/...
  OVERRIDES_DIR="$REPO_DIR/overrides/$CURRENT_USER"

  # --- HELPER: COPY FUNCTION ---
  sync_path() {
      local TARGET="$1"
      local ABS_FILE
      ABS_FILE=$(realpath "$TARGET")
      local HOME_DIR
      HOME_DIR=$(realpath "$HOME")

      # Validation
      if [[ "$ABS_FILE" != "$HOME_DIR"* ]]; then
          echo "Skipping $TARGET: Must be inside home directory."
          return
      fi

      # Calculate Relative Path (e.g., .config/nvim)
      local REL_PATH="''${ABS_FILE#$HOME_DIR/}"
      local DEST_PATH="$OVERRIDES_DIR/$REL_PATH"
      local DEST_DIR
      DEST_DIR=$(dirname "$DEST_PATH")

      if [ ! -d "$DEST_DIR" ]; then
          mkdir -p "$DEST_DIR"
      fi

      if [ -e "$DEST_PATH" ]; then
          rm -rf "$DEST_PATH"
      fi

      cp -r "$ABS_FILE" "$DEST_PATH"
      echo "  -> Synced: $REL_PATH"
  }

  # --- MODE 1: SYNC ALL (No Args) ---
  if [ -z "$1" ] || [ "$1" == "all" ]; then
      echo "Saving tracked files to overrides/$CURRENT_USER/..."
      
      if [ ! -f "$TRACKFILE" ]; then
          echo "No tracking file found."
          echo "Run 'prism-save <file>' to start tracking a file."
          exit 0
      fi

      while IFS= read -r line; do
          # Skip empty/comments
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
      exit 0
  fi

  # --- MODE 2: TRACK & SAVE (Arg Provided) ---
  TARGET_FILE="$1"

  if [ ! -e "$TARGET_FILE" ]; then
      echo "Error: File '$TARGET_FILE' does not exist."
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
''
