{ pkgs }:

pkgs.writeShellApplication {
  name = "prism-update-check";

  runtimeInputs = with pkgs; [
    coreutils
    curl
    jq
    gnused
    libnotify # For notify-send
  ];

  text = ''
    # Configuration
    FLAKE_FILE="/etc/prism/flake.nix"
    REPO_OWNER="otaleghani"
    REPO_NAME="prism"

    # 1. Parse current state from flake.nix
    # We look for the line: prism.url = "..."
    if [ ! -f "$FLAKE_FILE" ]; then
        echo "" # Warning icon if file missing
        exit 1
    fi

    URL_LINE=$(grep 'prism.url =' "$FLAKE_FILE")

    # 2. Check for Unstable Branch
    # If the URL ends with just the repo name (no tag), it's unstable/main
    # Regex: matches "github:owner/repo";
    if [[ "$URL_LINE" =~ github:''${REPO_OWNER}/''${REPO_NAME}\";$ ]]; then
        echo "" # Nerd Font: Branch/Code icon (Unstable)
        exit 0
    fi

    # 3. Extract Current Tag (Stable)
    # Removes everything before the slash after repo name, and removes trailing ";
    CURRENT_TAG=$(echo "$URL_LINE" | sed -E "s|.*''${REPO_NAME}/(.*)\";|\1|")

    # 4. Fetch Latest Tag from GitHub
    # Timeout set to 5s so your bar doesn't freeze if offline
    LATEST_JSON=$(curl -s --max-time 5 "https://api.github.com/repos/''${REPO_OWNER}/''${REPO_NAME}/releases/latest")

    # If curl failed (offline), show a distinct icon or just the current status
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
