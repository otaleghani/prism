{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
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

  # Header display
  clear
  gum style --border double --margin "1 2" --padding "1 2" --foreground 1 "Prism Package Removal"

  # Data collection
  # Parses the imperative Nix profile to map index keys to package names
  LIST=$(nix profile list --json | jq -r '.elements | to_entries | .[] | "\(.key) \(.value.storePaths[0] | split("-")[1:])"')

  if [ -z "$LIST" ]; then
    echo "No imperative packages found in the current profile."
    notify-send "Prism Store" "Removal cancelled: No packages found." -u low
    
    echo "Press any key to exit..."
    read -n 1 -s
    exit 0
  fi

  # Selection interface
  # Provides a multi-select filter to choose packages for removal
  echo "Select packages to remove (Space to mark, Enter to confirm):"
  SELECTED_LINES=$(echo "$LIST" | gum filter --no-limit --placeholder "Filter packages...")

  if [ -z "$SELECTED_LINES" ]; then
    echo "No packages selected. Exiting."
    exit 0
  fi

  # Extraction logic
  # Isolates the index numbers for the nix profile remove command
  INDICES=$(echo "$SELECTED_LINES" | awk '{print $1}' | tr '\n' ' ')

  # Execution logic
  echo "Removing indices: $INDICES"
  if nix profile remove $INDICES; then
    notify-send "Prism Store" "Packages removed successfully." -i trash-can
  else
    notify-send "Prism Store" "Failed to remove packages. Profile might be locked." -u critical
    
    # Error persistence
    echo "Error: Nix profile modification failed."
    echo "Press any key to exit..."
    read -n 1 -s
    exit 1
  fi

  echo "Operation complete."
''
