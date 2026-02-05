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
  ];

  # --- RESET LOGIC ---
  resetScript = ''
    reset_dotfiles() {
      CONFIG_DIR="$1"
      echo "!!! WARNING: You are about to reset Prism dotfiles to defaults. !!!"
      echo "This will delete local modifications to files managed by Prism."
      echo "Files in 'overrides/' will be preserved and reapplied."
      echo ""
      read -p "Are you sure? (y/N) " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          echo "Aborting."
          exit 1
      fi

      echo "Locating Prism defaults..."
      # FIX: We need to find where the 'prism' input is stored in the Nix Store.
      # We use nix eval to get the outPath of the input defined in flake.nix
      PRISM_SRC=$(nix eval --raw --extra-experimental-features 'nix-command flakes' --expr "(builtins.getFlake \"$CONFIG_DIR\").inputs.prism.outPath")
      
      DEFAULTS_DIR="$PRISM_SRC/defaults"
      echo "Scanning defaults at: $DEFAULTS_DIR"
      
      if [ -d "$DEFAULTS_DIR" ]; then
          # Find files, EXCLUDING themes, wallpapers, and templates
          # (These map to .local/share, not root of home, so the path logic below would be wrong for them)
          find "$DEFAULTS_DIR" -type f \
            -not -path "*/themes/*" \
            -not -path "*/wallpapers/*" \
            -not -path "*/templates/*" \
            | while read -r file; do
            
              # Strip prefix: .../defaults/common/.config/foo -> common/.config/foo
              REL_PATH="''${file#$DEFAULTS_DIR/}"
              
              # Strip first directory (layer): common/.config/foo -> .config/foo
              TARGET_REL="''${REL_PATH#*/}"
              
              TARGET_ABS="$HOME/$TARGET_REL"
              
              if [ -f "$TARGET_ABS" ]; then
                  rm "$TARGET_ABS"
                  echo "  - Deleted: $TARGET_REL"
              fi
          done
      else
          echo "Error: Could not locate defaults directory."
      fi
      echo "Cleanup complete. Rebuilding will generate fresh defaults."
    }
  '';

  # --- 1. UNSTABLE UPDATE ---
  updateUnstable = writeShellScriptBin "prism-update-unstable" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    ${resetScript}

    RESET="false"
    ARGS=""
    for arg in "$@"; do
        case $arg in
            --reset-dotfiles) RESET="true" ;;
            *) ARGS="$ARGS $arg" ;;
        esac
    done

    if [ -d "/etc/prism" ]; then
        CONFIG_DIR="/etc/prism"
    elif [ -d "$HOME/.config/prism" ]; then
        CONFIG_DIR="$HOME/.config/prism"
    else
        CONFIG_DIR="''${1:-/etc/nixos}"
    fi

    if [ ! -f "$CONFIG_DIR/flake.nix" ]; then
      echo "Error: No flake.nix found in '$CONFIG_DIR'"
      exit 1
    fi

    if [ "$RESET" == "true" ]; then
        reset_dotfiles "$CONFIG_DIR"
    fi

    echo "=========================================="
    echo "   Updating Prism (UNSTABLE / LATEST)     "
    echo "=========================================="

    echo "[1/2] Fetching latest commits..."
    sudo nix flake lock --update-input prism --commit-lock-file "$CONFIG_DIR"

    echo "[2/2] Rebuilding system..."
    sudo nixos-rebuild switch --flake "$CONFIG_DIR#prism"

    echo "=========================================="
    echo "   Update Complete! (Unstable Channel)    "
    echo "=========================================="
  '';

  # --- 2. STABLE UPDATE ---
  updateStable = writeShellScriptBin "prism-update" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    ${resetScript}

    RESET="false"
    ARGS=""
    for arg in "$@"; do
        case $arg in
            --reset-dotfiles) RESET="true" ;;
            *) ARGS="$ARGS $arg" ;;
        esac
    done

    if [ -d "/etc/prism" ]; then
        CONFIG_DIR="/etc/prism"
    elif [ -d "$HOME/.config/prism" ]; then
        CONFIG_DIR="$HOME/.config/prism"
    else
        CONFIG_DIR="''${1:-/etc/nixos}"
    fi

    if [ ! -f "$CONFIG_DIR/flake.nix" ]; then
      echo "Error: No flake.nix found in '$CONFIG_DIR'"
      exit 1
    fi

    if [ "$RESET" == "true" ]; then
        reset_dotfiles "$CONFIG_DIR"
    fi

    echo "=========================================="
    echo "   Updating Prism (STABLE RELEASE)        "
    echo "=========================================="

    echo "[1/3] Checking for updates..."
    LATEST_TAG=$(curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name")

    if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
        echo "Error: Could not fetch latest release tag from GitHub."
        exit 1
    fi

    echo "Found Release: $LATEST_TAG"

    echo "[2/3] Locking dependencies..."
    sudo nix flake lock --override-input prism "github:otaleghani/prism/$LATEST_TAG" --commit-lock-file "$CONFIG_DIR"

    echo "[3/3] Rebuilding system..."
    sudo nixos-rebuild switch --flake "$CONFIG_DIR#prism"

    echo "=========================================="
    echo "   Update Complete! (Version: $LATEST_TAG)"
    echo "=========================================="
  '';

in
symlinkJoin {
  name = "prism-update-suite";
  paths = [
    updateUnstable
    updateStable
  ];
}
