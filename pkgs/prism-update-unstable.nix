# prism-update fetches and installs the latest version of prism
{
  writeShellScriptBin,
}:

writeShellScriptBin "prism-update-unstable" ''
  # Usage: prism-update [path/to/config]
  # Defaults to current directory if no path provided
  CONFIG_DIR="$HOME/.config/prism"

  if [ ! -f "$CONFIG_DIR/flake.nix" ]; then
    echo "Error: No flake.nix found in '$CONFIG_DIR'"
    echo "Usage: prism-update <path-to-your-config>"
    echo "   or: cd /etc/nixos && prism-update"
    exit 1
  fi

  echo "=========================================="
  echo "   Updating Prism & System Dependencies   "
  echo "=========================================="

  # Update the 'prism' input specifically
  # This fetches the latest commit from your GitHub repo
  echo "[1/2] Fetching latest Prism version..."
  sudo nix flake lock --update-input prism --commit-lock-file "$CONFIG_DIR"

  # Rebuild the system
  # This triggers the activation scripts (rsync scaffolding)
  echo "[2/2] Rebuilding system..."
  sudo nixos-rebuild switch --flake "$CONFIG_DIR#prism"

  echo "=========================================="
  echo "   Update Complete!                       "
  echo "=========================================="
  echo "Note: Configuration files are only copied if they don't exist locally."
  echo "To reset a config file to the new Prism default, delete your local copy."
''
