{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.fzf
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

  # Database validation
  if [ ! -f "$CACHE_FILE" ]; then
    echo "Package database not found. Synchronizing..."
    prism-sync || {
        notify-send "Prism Store" "Failed to sync package database." -u critical
        exit 1
    }
  fi

  # Selection interface
  # High-performance search through cached nixpkgs
  SELECTED_LINE=$(cat "$CACHE_FILE" | fzf \
    --prompt="Install> " \
    --layout=reverse \
    --height=80% \
    --border \
    --preview "echo {2..}" \
    --preview-window="top:3:wrap" \
    --with-nth=1 \
    --header="Search Nixpkgs Database")

  if [ -z "$SELECTED_LINE" ]; then
    exit 0
  fi

  # Extraction logic
  PKG=$(echo "$SELECTED_LINE" | awk '{print $1}')

  # Execution logic
  echo "Installing $PKG..."
  if nix profile install "nixpkgs#$PKG"; then
    notify-send "Prism Store" "Successfully installed $PKG" -i system-software-install
  else
    notify-send "Prism Store" "Failed to install $PKG." -u critical
    
    # Error persistence
    echo "Error: Installation failed."
    echo "Press any key to exit..."
    read -n 1 -s
    exit 1
  fi
''
