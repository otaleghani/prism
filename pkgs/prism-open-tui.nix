{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.jq
  ];
in
writeShellScriptBin "prism-tui" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH
  # Usage: prism-tui <command> [args...]
  # Example: prism-tui btop
  # Example: prism-tui nvim /path/to/file

  if [ -z "$1" ]; then
    echo "Usage: prism-tui <command> [args...]"
    exit 1
  fi

  CMD="$1"
  BASENAME=$(basename "$CMD")

  # Construct a unique App ID
  # This allows you to target this specific window in Hyprland config
  # e.g. windowrulev2 = float,class:^(org.prism.btop)$
  APP_ID="org.prism.$BASENAME"

  # Check for ghostty (Prism's default terminal)
  if ! command -v ghostty >/dev/null; then
    echo "Error: 'ghostty' terminal not found."
    echo "Prism TUI launcher requires ghostty."
    exit 1
  fi

  echo "[Prism] Launching TUI: $CMD (Class: $APP_ID)"

  # Launch detached
  # --class sets the Wayland app_id
  # "$@" passes the command and ALL arguments to ghostty
  # setsid ghostty --class "$APP_ID" "$@" >/dev/null 2>&1 &
  setsid ghostty --class="$APP_ID" -e "$@" >/dev/null 2>&1 &
''
