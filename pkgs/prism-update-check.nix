{ pkgs }:

pkgs.writeShellApplication {
  name = "prism-update-check";

  runtimeInputs = with pkgs; [
    coreutils
    curl
    jq
    gnused
    libnotify
  ];

  text = ''
    # Configuration
    FLAKE_FILE="/etc/prism/flake.nix"
    REPO_OWNER="otaleghani"
    REPO_NAME="prism"

    # 1. Parse current state from flake.nix
    if [ ! -f "$FLAKE_FILE" ]; then
        echo "" # Warning icon if file missing
        exit 1
    fi

    # Extract the full line: prism.url = "..."
    URL_LINE=$(grep 'prism.url =' "$FLAKE_FILE")

    # Clean extraction of the URL content inside the quotes
    # Matches: anything -> prism.url = " -> (capture this) -> ";
    CURRENT_URL=$(echo "$URL_LINE" | sed -n 's/.*prism.url = "\(.*\)";.*/\1/p')

    # Construct the base "Unstable" URL
    BASE_URL="github:''${REPO_OWNER}/''${REPO_NAME}"

    # 2. Check for Unstable Branch
    # If the URL is exactly "github:owner/repo", it is unstable (no tag)
    if [ "$CURRENT_URL" == "$BASE_URL" ]; then
        echo "" # Nerd Font: Branch/Code icon (Unstable)
        exit 0
    fi

    # 3. Extract Current Tag (Stable)
    # If we are here, the URL is likely "github:owner/repo/v1.0.0"
    # We strip the base URL + slash to get the tag.
    # We quote "''${BASE_URL}" inside the expansion to satisfy shellcheck SC2295.
    CURRENT_TAG="''${CURRENT_URL#"''${BASE_URL}"/}"

    # 4. Fetch Latest Tag from GitHub
    LATEST_JSON=$(curl -s --max-time 5 "https://api.github.com/repos/''${REPO_OWNER}/''${REPO_NAME}/releases/latest")

    if [ -z "$LATEST_JSON" ]; then
        echo "" # Disconnected/Offline icon
        exit 0
    fi

    LATEST_TAG=$(echo "$LATEST_JSON" | jq -r '.tag_name')

    # 5. Compare and Notify
    if [ "$CURRENT_TAG" == "$LATEST_TAG" ]; then
        echo "" # Check icon (Up to date)
    else
        echo "󰚰" # Update icon (Update available)
        
        # Send notification
        notify-send -u normal \
            -i software-update-available \
            "PrismOS Update" \
            "Version $LATEST_TAG is available!\n(Current: $CURRENT_TAG)"
    fi
  '';
}
