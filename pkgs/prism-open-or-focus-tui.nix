{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils # for basename
  ];
in
writeShellScriptBin "prism-focus-tui" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Usage: prism-focus-tui <command> [args...]
  # Ensures only one instance of the TUI command is running.
  # Example: prism-focus-tui btop
  # Example: prism-focus-tui nvim /path/to/project

  if [ -z "$1" ]; then
    echo "Usage: prism-focus-tui <command> [args...]"
    exit 1
  fi

  CMD="$1"
  BASENAME=$(basename "$CMD")

  # Generate the expected App ID (Must match logic in prism-tui)
  APP_ID="org.prism.$BASENAME"

  # Construct the launch command
  # We delegate the actual launching to prism-tui
  # We use printf %q to safely escape arguments (e.g. filenames with spaces)
  LAUNCH_COMMAND="prism-tui"
  for arg in "$@"; do
    LAUNCH_COMMAND="$LAUNCH_COMMAND $(printf %q "$arg")"
  done

  # Hand off to prism-focus
  # Arg 1: The App ID to search for (Class name)
  # Arg 2: The command to run if not found
  exec prism-focus "$APP_ID" "$LAUNCH_COMMAND"
''
