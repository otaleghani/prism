{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.jq
  ];
in
writeShellScriptBin "prism-save" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Usage: prism-save <file_or_folder>
  # Example: prism-save ~/.config/hypr/monitors.conf
  # Example: prism-save ~/.config/nvim

  TARGET_FILE="$1"

  if [ -z "$TARGET_FILE" ]; then
    echo "Usage: prism-save <file_or_folder_path>"
    echo "Copies a file/folder from Home to Prism Flake overrides."
    exit 1
  fi

  # Resolve Absolute Paths
  ABS_FILE=$(realpath "$TARGET_FILE")
  HOME_DIR=$(realpath "$HOME")

  # Ensure file is actually in Home
  if [[ "$ABS_FILE" != "$HOME_DIR"* ]]; then
    echo "Error: Path must be inside your home directory."
    exit 1
  fi

  # Setup Prism Repo Location
  REPO_DIR="$HOME/.config/prism"
  OVERRIDES_DIR="$REPO_DIR/overrides"

  if [ ! -d "$REPO_DIR" ]; then
      echo "Error: Prism repository not found at $REPO_DIR"
      echo "Please move or clone your flake to ~/.config/prism"
      exit 1
  fi

  # Calculate Relative Path
  # Remove $HOME/ prefix to get relative path (e.g. .config/nvim)
  # FIX: We use ''${...} to escape the bash syntax from Nix interpolation
  REL_PATH="''${ABS_FILE#$HOME_DIR/}"
  DEST_PATH="$OVERRIDES_DIR/$REL_PATH"
  DEST_DIR=$(dirname "$DEST_PATH")

  # Copy File or Directory
  if [ ! -d "$DEST_DIR" ]; then
    echo "Creating parent directory: $DEST_DIR"
    mkdir -p "$DEST_DIR"
  fi

  # FIX: Remove destination first to prevent nesting and ensure clean state
  # If we don't do this, 'cp -r dir existing_dir' creates 'existing_dir/dir'
  if [ -e "$DEST_PATH" ]; then
      echo "Overwriting existing override..."
      rm -rf "$DEST_PATH"
  fi

  echo "Copying $REL_PATH -> overrides/..."
  # -r allows copying directories recursively
  cp -r "$ABS_FILE" "$DEST_PATH"

  echo "✅ Saved to $DEST_PATH"
  echo "Don't forget to 'git add' and commit!"
''
