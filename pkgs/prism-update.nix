{ pkgs }:

pkgs.writeShellApplication {
  name = "prism-update";

  # Dependencies available inside the script
  runtimeInputs = with pkgs; [
    coreutils
    curl
    jq
    fzf
    gnugrep
    gnused
    git
    libnotify
    nix
    nixos-rebuild
  ];

  text = ''
    # Configuration
    FLAKE_DIR="/etc/prism"
    FLAKE_FILE="$FLAKE_DIR/flake.nix"
    REPO_OWNER="otaleghani"
    REPO_NAME="prism"
    REPO_GIT_URL="git+https://github.com/''${REPO_OWNER}/''${REPO_NAME}.git"

    run_as_root() {
        if [ "$(id -u)" -eq 0 ]; then
            "$@"
        elif [ -x /run/wrappers/bin/sudo ]; then
            /run/wrappers/bin/sudo "$@"
        else
            sudo "$@"
        fi
    }

    curl_args=(-s -f)
    if [[ -n "''${GITHUB_TOKEN:-}" ]]; then
        curl_args+=(-H "Authorization: Bearer ''${GITHUB_TOKEN}")
    fi

    print_rate_limit_help() {
        printf '%s\n' \
            "" \
            "GitHub rate limit hit while updating flakes." \
            "Retry later, or set a GitHub token for Nix:" \
            "  mkdir -p ~/.config/nix" \
            "  printf 'access-tokens = github.com=YOUR_TOKEN\\n' >> ~/.config/nix/nix.conf" \
            "" \
            "For one-off release discovery, you can also run:" \
            "  GITHUB_TOKEN=YOUR_TOKEN prism-update"
    }

    fetch_release_tags() {
        local releases_json
        if releases_json=$(curl "''${curl_args[@]}" "https://api.github.com/repos/''${REPO_OWNER}/''${REPO_NAME}/releases"); then
            echo "$releases_json" | jq -r '.[].tag_name'
            return 0
        fi

        echo "Warning: Could not fetch GitHub releases through the API." >&2
        echo "Falling back to repository tags..." >&2
        git ls-remote --refs --tags "https://github.com/''${REPO_OWNER}/''${REPO_NAME}.git" \
            | sed 's|.*refs/tags/||' \
            | sort -Vr
    }

    # Mode selection 

    if [[ "''${1:-}" == "unstable" ]]; then
        echo "Switching to UNSTABLE (tracking main)..."
        NEW_URL="''${REPO_GIT_URL}?ref=main"
        TARGET_LABEL="unstable main"
    else
        echo "Fetching releases for ''${REPO_NAME}..."

        if ! TAGS=$(fetch_release_tags); then
            echo "Error: Could not fetch releases or tags from GitHub."
            exit 1
        fi

        if [[ -z "$TAGS" || "$TAGS" == "null" ]]; then
            echo "Error: No release tags found."
            exit 1
        fi

        if ! SELECTED_TAG=$(echo "$TAGS" | fzf --prompt="Select Prism Version > " --height=40% --layout=reverse --border); then
             echo "No version selected. Operation cancelled."
             exit 0
        fi

        echo "Selected version: $SELECTED_TAG"
        NEW_URL="''${REPO_GIT_URL}?ref=''${SELECTED_TAG}"
        TARGET_LABEL="$SELECTED_TAG"
    fi

    # Apply changes

    if [ ! -f "$FLAKE_FILE" ]; then
        echo "Error: $FLAKE_FILE does not exist."
        exit 1
    fi

    echo "Updating flake input in $FLAKE_FILE..."

    # Create backup
    cp "$FLAKE_FILE" "''${FLAKE_FILE}.bak"
    HAD_LOCK=0
    if [ -f "$FLAKE_DIR/flake.lock" ]; then
        cp "$FLAKE_DIR/flake.lock" "$FLAKE_DIR/flake.lock.bak"
        HAD_LOCK=1
    fi

    # Use sed to replace the prism.url line.
    # We use | as delimiter to handle forward slashes in URL safely.
    sed -i "s|prism.url = \".*\";|prism.url = \"$NEW_URL\";|" "$FLAKE_FILE"

    # Verify change
    if grep -Fq "$NEW_URL" "$FLAKE_FILE"; then
        echo "   Input updated to $NEW_URL"
    else
        echo "   Error: Failed to update flake.nix. Restoring backup."
        mv "''${FLAKE_FILE}.bak" "$FLAKE_FILE"
        exit 1
    fi

    # Rebuild System 

    echo "Updating flake lockfile..."
    # This updates flake.lock to match the new version
    LOCK_LOG=$(mktemp)
    if ! nix flake update --flake "$FLAKE_DIR" 2> >(tee "$LOCK_LOG" >&2); then
        echo "Error: Failed to update flake.lock. Restoring previous flake files."
        mv "''${FLAKE_FILE}.bak" "$FLAKE_FILE"
        if [ "$HAD_LOCK" -eq 1 ] && [ -f "$FLAKE_DIR/flake.lock.bak" ]; then
            mv "$FLAKE_DIR/flake.lock.bak" "$FLAKE_DIR/flake.lock"
        else
            rm -f "$FLAKE_DIR/flake.lock"
        fi
        if grep -qi "rate limit" "$LOCK_LOG"; then
            print_rate_limit_help
        fi
        rm -f "$LOCK_LOG"
        exit 1
    fi
    rm -f "$LOCK_LOG"
    rm -f "''${FLAKE_FILE}.bak" "$FLAKE_DIR/flake.lock.bak"

    echo "Rebuilding NixOS configuration..."
    # NixOS exposes setuid sudo through /run/wrappers/bin, not the Nix store binary.
    if run_as_root nixos-rebuild switch --flake "''${FLAKE_DIR}#prism"; then
        notify-send "Prism Update" "Successfully updated to $TARGET_LABEL." -i system-software-update
        echo "Update Complete!"
    else
        notify-send "Prism Update" "System rebuild failed." -u critical
        exit 1
    fi
  '';
}
