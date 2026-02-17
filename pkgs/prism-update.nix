{ pkgs }:

pkgs.writeShellApplication {
  name = "prism-update";

  # Dependencies available inside the script
  runtimeInputs = with pkgs; [
    coreutils
    curl
    jq
    fzf
    gnused
    git
    nix
    nixos-rebuild
  ];

  text = ''
    # Configuration
    FLAKE_DIR="/etc/prism"
    FLAKE_FILE="$FLAKE_DIR/flake.nix"
    REPO_OWNER="otaleghani"
    REPO_NAME="prism"

    # Mode selection 

    if [[ "''${1:-}" == "unstable" ]]; then
        echo "Switching to UNSTABLE (tracking main/master)..."
        NEW_URL="github:''${REPO_OWNER}/''${REPO_NAME}"
    else
        echo "Fetching releases for ''${REPO_NAME}..."
        
        # Fetch releases from GitHub API
        if ! RELEASES_JSON=$(curl -s -f "https://api.github.com/repos/''${REPO_OWNER}/''${REPO_NAME}/releases"); then
            echo "Error: Could not fetch releases from GitHub."
            exit 1
        fi

        TAGS=$(echo "$RELEASES_JSON" | jq -r '.[].tag_name')

        if [[ -z "$TAGS" || "$TAGS" == "null" ]]; then
            echo "Error: No release tags found."
            exit 1
        fi

        # Pipe tags into fzf
        # We explicitly read from /dev/tty to ensure fzf interactive mode works
        SELECTED_TAG=$(echo "$TAGS" | fzf --prompt="Select Prism Version > " --height=40% --layout=reverse --border < /dev/tty)

        if [[ -z "$SELECTED_TAG" ]]; then
            echo "No version selected. Operation cancelled."
            exit 0
        fi

        echo "Selected version: $SELECTED_TAG"
        NEW_URL="github:''${REPO_OWNER}/''${REPO_NAME}/''${SELECTED_TAG}"
    fi

    # Apply changes

    if [ ! -f "$FLAKE_FILE" ]; then
        echo "Error: $FLAKE_FILE does not exist."
        exit 1
    fi

    echo "Updating flake input in $FLAKE_FILE..."

    # Create backup
    cp "$FLAKE_FILE" "''${FLAKE_FILE}.bak"

    # Use sed to replace the prism.url line.
    # We use | as delimiter to handle forward slashes in URL safely.
    sed -i "s|prism.url = \".*\";|prism.url = \"$NEW_URL\";|" "$FLAKE_FILE"

    # Verify change
    if grep -q "$NEW_URL" "$FLAKE_FILE"; then
        echo "   Input updated to $NEW_URL"
    else
        echo "   Error: Failed to update flake.nix. Restoring backup."
        mv "''${FLAKE_FILE}.bak" "$FLAKE_FILE"
        exit 1
    fi

    # Rebuild System 

    echo "Updating flake lockfile..."
    # This updates flake.lock to match the new version
    nix flake update --flake "$FLAKE_DIR"

    echo "Rebuilding NixOS configuration..."
    # If this step requires root, nixos-rebuild will ask for password via sudo/polkit
    if sudo nixos-rebuild switch --flake "''${FLAKE_DIR}#prism"; then
        notify-send "Prism Update" "Successfully updated to $LATEST_TAG." -i system-software-update
        echo "Update Complete!"
    else
        notify-send "Prism Update" "System rebuild failed." -u critical
        exit 1
    fi
  '';
}
