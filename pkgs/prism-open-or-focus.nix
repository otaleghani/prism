{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.jq
  ];
in
writeShellScriptBin "prism-focus" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Usage: prism-focus <window-pattern> [launch-command]
  # Example: prism-focus "spotify" 
  # Example: prism-focus "firefox" "firefox --private-window"

  if (($# == 0)); then
    echo "Usage: prism-focus [window-pattern] [launch-command]"
    exit 1
  fi

  WINDOW_PATTERN="$1"
  # If 2nd arg is provided, use it. Otherwise, assume the pattern IS the command.
  LAUNCH_COMMAND="''${2:-$WINDOW_PATTERN}"

  # Query Hyprland for clients
  # We use jq to filter for a matching class or title
  # The regex "\\b" + $p + "\\b" ensures we match whole words (e.g. "term" won't match "terminal")
  WINDOW_ADDRESS=$(hyprctl clients -j | jq -r --arg p "$WINDOW_PATTERN" '.[] | select((.class | test("\\b" + $p + "\\b";"i")) or (.title | test("\\b" + $p + "\\b";"i"))) | .address' | head -n1)

  if [[ -n "$WINDOW_ADDRESS" ]]; then
    echo "[Prism] Found existing window ($WINDOW_ADDRESS). Focusing..."
    hyprctl dispatch focuswindow "address:$WINDOW_ADDRESS"
  else
    echo "[Prism] Window not found. Launching: $LAUNCH_COMMAND"
    # Use hyprctl dispatch exec to launch the app cleanly within the Hyprland session.
    # This is more reliable than 'setsid' as it ensures the app inherits the correct WM environment.
    hyprctl dispatch exec "$LAUNCH_COMMAND"
  fi
''
