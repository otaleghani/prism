# prism-update fetches and installs the latest version of prism
{
  pkgs,
  writeShellScriptBin,
}:
let
  # Dependencies for fetching release info
  deps = [
    pkgs.curl
    pkgs.jq
  ];
in
# Updates to the latest GitHub Release Tag
writeShellScriptBin "prism-update" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_DIR="''${1:-/etc/prism}"

  if [ ! -f "$CONFIG_DIR/flake.nix" ]; then
    echo "Error: No flake.nix found in '$CONFIG_DIR'"
    exit 1
  fi

  echo "=========================================="
  echo "   Updating Prism (STABLE RELEASE)        "
  echo "=========================================="

  # Fetch Latest Tag from GitHub API
  echo "[1/3] Checking for updates..."
  LATEST_TAG=$(curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name")

  if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
      echo "Error: Could not fetch latest release tag from GitHub."
      exit 1
  fi

  echo "Found Release: $LATEST_TAG"

  # Override the input to pin the specific tag
  # This modifies flake.lock to point to the tag instead of the branch
  echo "[2/3] Locking dependencies..."
  sudo nix flake lock --override-input prism "github:otaleghani/prism/$LATEST_TAG" --commit-lock-file "$CONFIG_DIR"

  # Rebuild
  echo "[3/3] Rebuilding system..."
  sudo nixos-rebuild switch --flake "$CONFIG_DIR#prism"

  echo "=========================================="
  echo "   Update Complete! (Version: $LATEST_TAG)"
  echo "=========================================="
''
