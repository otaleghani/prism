{ pkgs }:

pkgs.writeShellApplication {
  name = "prism-update-check";

  runtimeInputs = with pkgs; [
    coreutils
    curl
    git
    gnugrep
    jq
    gnused
    libnotify
  ];

  text = ''
    # Configuration
    FLAKE_FILE="/etc/prism/flake.nix"
    REPO_OWNER="otaleghani"
    REPO_NAME="prism"
    GITHUB_BASE="github:''${REPO_OWNER}/''${REPO_NAME}"
    GIT_BASE="git+https://github.com/''${REPO_OWNER}/''${REPO_NAME}.git"

    curl_args=(-s --max-time 5)
    if [[ -n "''${GITHUB_TOKEN:-}" ]]; then
        curl_args+=(-H "Authorization: Bearer ''${GITHUB_TOKEN}")
    fi

    latest_tag() {
        local latest_json latest

        latest_json=$(curl "''${curl_args[@]}" "https://api.github.com/repos/''${REPO_OWNER}/''${REPO_NAME}/releases/latest" || true)
        latest=$(echo "$latest_json" | jq -r 'if type == "object" then (.tag_name // empty) else empty end' 2>/dev/null || true)

        if [ -n "$latest" ] && [ "$latest" != "null" ]; then
            echo "$latest"
            return 0
        fi

        git ls-remote --refs --tags "https://github.com/''${REPO_OWNER}/''${REPO_NAME}.git" 2>/dev/null \
            | sed 's|.*refs/tags/||' \
            | sort -Vr \
            | head -n 1
    }

    # Parse current state from flake.nix
    if [ ! -f "$FLAKE_FILE" ]; then
        echo ""
        exit 1
    fi

    # Extract the full line: prism.url = "..."
    URL_LINE=$(grep 'prism.url =' "$FLAKE_FILE")

    # Clean extraction of the URL content inside the quotes
    # Matches: anything -> prism.url = " -> (capture this) -> ";
    CURRENT_URL=$(echo "$URL_LINE" | sed -n 's/.*prism.url = "\(.*\)";.*/\1/p')

    # Check for Unstable Branch
    # Older configs use github:owner/repo; newer configs avoid GitHub API rate limits with git+https.
    if [ "$CURRENT_URL" == "$GITHUB_BASE" ] || [ "$CURRENT_URL" == "''${GIT_BASE}?ref=main" ]; then
        echo "" # Nerd Font: Branch/Code icon (Unstable)
        exit 0
    fi

    # Extract Current Tag (Stable). Supports both github:owner/repo/tag and git+https://...?ref=tag.
    if [[ "$CURRENT_URL" == "''${GITHUB_BASE}/"* ]]; then
        CURRENT_TAG="''${CURRENT_URL#"''${GITHUB_BASE}"/}"
    elif [[ "$CURRENT_URL" == "''${GIT_BASE}?ref="* ]]; then
        CURRENT_TAG="''${CURRENT_URL#"''${GIT_BASE}"?ref=}"
    else
        echo ""
        exit 0
    fi

    # Fetch Latest Tag from GitHub, falling back to Git tags when the API is unavailable or rate-limited.
    LATEST_TAG=$(latest_tag || true)

    if [ -z "$LATEST_TAG" ]; then
        echo "" # Disconnected/Offline icon
        exit 0
    fi

    # Compare and Notify
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
