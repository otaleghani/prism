{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.fzf
    pkgs.jq
    pkgs.gawk
    pkgs.libnotify
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-delete" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Terminal auto-launch
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        exec prism-tui "$0" "$@"
    else
        notify-send "Prism Store" "Terminal wrapper not found." -u critical
        exit 1
    fi
  fi

  # Data collection
  # Parses imperative profile for removal indices
  LIST=$(nix profile list --json | jq -r '.elements | to_entries | .[] | "\(.key) \(.value.storePaths[0] | split("-")[1:])"')

  if [ -z "$LIST" ]; then
    notify-send "Prism Store" "No packages found to remove." -u low
    exit 0
  fi

  # Selection interface
  # Multi-select supported via TAB
  SELECTED_LINES=$(echo "$LIST" | fzf \
    --prompt="Remove> " \
    --layout=reverse \
    --height=50% \
    --border \
    --multi \
    --header="Select packages to remove (TAB to multi-select)")

  if [ -z "$SELECTED_LINES" ]; then
    exit 0
  fi

  # Extraction logic
  INDICES=$(echo "$SELECTED_LINES" | awk '{print $1}' | tr '\n' ' ')

  # Execution logic
  echo "Removing indices: $INDICES"
  if nix profile remove $INDICES; then
    notify-send "Prism Store" "Packages removed successfully." -i trash-can
  else
    notify-send "Prism Store" "Failed to remove packages." -u critical
    
    # Error persistence
    echo "Error: Modification failed."
    echo "Press any key to exit..."
    read -n 1 -s
    exit 1
  fi
''
