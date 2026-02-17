{
  pkgs,
  writeShellScriptBin,
  symlinkJoin,
}:

let
  deps = [
    pkgs.curl
    pkgs.jq
    pkgs.coreutils
    pkgs.findutils
    pkgs.nix
    pkgs.libnotify
  ];

  # Helper: Configuration discovery
  # Locates the system flake directory in standard Prism locations
  configDiscovery = ''
    if [ -d "/etc/prism" ]; then
        CONFIG_DIR="/etc/prism"
    elif [ -d "$HOME/.config/prism" ]; then
        CONFIG_DIR="$HOME/.config/prism"
    else
        CONFIG_DIR="''${1:-/etc/nixos}"
    fi

    if [ ! -f "$CONFIG_DIR/flake.nix" ]; then
      notify-send "Prism Update" "Error: Flake configuration not found." -u critical
      exit 1
    fi
  '';

  # UNSTABLE UPDATE
  # Tracks the latest commits on the main branch
  updateUnstable = writeShellScriptBin "prism-update-unstable-old" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    ${configDiscovery}

    echo "=========================================="
    echo "    Updating Prism (UNSTABLE / LATEST)    "
    echo "=========================================="

    # Lockfile management
    # Pulls the latest commit hash for the Prism input
    echo "[1/2] Fetching latest commits..."
    sudo nix flake lock --update-input prism --commit-lock-file "$CONFIG_DIR" || {
        notify-send "Prism Update" "Failed to update flake lock." -u critical
        exit 1
    }

    # System generation
    # Rebuilds the NixOS system profile
    echo "[2/2] Rebuilding system..."
    if sudo nixos-rebuild switch --flake "$CONFIG_DIR#prism"; then
        notify-send "Prism Update" "System updated to latest unstable successfully." -i system-software-update
        echo "Update Complete!"
    else
        notify-send "Prism Update" "System rebuild failed. Check logs." -u critical
        exit 1
    fi
  '';

  # STABLE UPDATE
  # Tracks official GitHub releases and tagged versions
  updateStable = writeShellScriptBin "prism-update-old" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    ${configDiscovery}

    echo "=========================================="
    echo "    Updating Prism (STABLE RELEASE)       "
    echo "=========================================="

    # Version discovery
    # Queries the GitHub API for the most recent release tag
    echo "[1/3] Checking for updates..."
    LATEST_TAG=$(curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name")

    if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
        notify-send "Prism Update" "Failed to fetch latest release tag." -u critical
        exit 1
    fi

    echo "Found Release: $LATEST_TAG"

    # Input overriding
    # Pins the flake input to the specific GitHub tag
    echo "[2/3] Locking dependencies..."
    sudo nix flake lock --override-input prism "github:otaleghani/prism/$LATEST_TAG" --commit-lock-file "$CONFIG_DIR" || {
        notify-send "Prism Update" "Failed to lock to $LATEST_TAG." -u critical
        exit 1
    }

    # System generation
    echo "[3/3] Rebuilding system..."
    if sudo nixos-rebuild switch --flake "$CONFIG_DIR#prism"; then
        notify-send "Prism Update" "Successfully updated to $LATEST_TAG." -i system-software-update
        echo "Update Complete!"
    else
        notify-send "Prism Update" "System rebuild failed." -u critical
        exit 1
    fi
  '';

in
symlinkJoin {
  name = "prism-update-suite";
  paths = [
    updateUnstable
    updateStable
  ];
}
