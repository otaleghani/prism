{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.jq
    pkgs.libnotify
    pkgs.coreutils
    pkgs.gawk
  ];
in
writeShellScriptBin "prism-install" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH
  CACHE_FILE="$HOME/.cache/prism/pkglist.txt"

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
  gum style --border double --margin "1 2" --padding "1 2" --foreground 2 "Prism Package Installer"

  # Database validation
  # Triggers a sync if the local package cache is missing
  if [ ! -f "$CACHE_FILE" ]; then
    echo "Package database not found. Synchronizing..."
    prism-sync || {
        notify-send "Prism Store" "Failed to sync package database." -u critical
        exit 1
    }
  fi

  # Selection interface
  # Uses gum filter to search through the cached package list
  echo "Search for a package to install:"
  SELECTED_LINE=$(cat "$CACHE_FILE" | gum filter --placeholder "Type to search...")

  if [ -z "$SELECTED_LINE" ]; then
    exit 0
  fi

  # Extraction logic
  # Isolates the attribute path from the description
  PKG=$(echo "$SELECTED_LINE" | awk '{print $1}')

  # Execution logic
  # Performs imperative installation into the user's nix profile
  echo "Installing $PKG..."
  if nix profile install "nixpkgs#$PKG"; then
    notify-send "Prism Store" "Successfully installed $PKG" -i system-software-install
  else
    notify-send "Prism Store" "Failed to install $PKG. Check network or package name." -u critical
    
    # Error persistence
    echo "Error: Installation failed."
    echo "Press any key to exit..."
    read -n 1 -s
    exit 1
  fi

  echo "Operation complete."
''
