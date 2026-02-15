{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.hyprland
    pkgs.coreutils
    pkgs.libnotify
    pkgs.gum
    pkgs.neovim
  ];
in
writeShellScriptBin "prism-monitor" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_FILE="$HOME/.config/hypr/monitors.conf"

  # Terminal auto-launch
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        exec prism-tui "$0" "$@"
    else
        notify-send "Prism Monitor" "Error: prism-tui not found. Ensure it is in your PATH." -u critical
        exit 1
    fi
  fi

  # Header display
  clear
  gum style --border double --margin "1 2" --padding "1 2" --foreground 4 "Prism Monitor Manager"

  # Ensure config exists
  if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "# Prism Monitor Configuration" > "$CONFIG_FILE"
    echo "monitor=,preferred,auto,1" >> "$CONFIG_FILE"
    echo "Default configuration file created."
  fi

  # Dynamic editor selection
  EDITOR_CMD="''${EDITOR:-nvim}"
  echo "Opening monitor layout with $EDITOR_CMD..."
  $EDITOR_CMD "$CONFIG_FILE"

  # Apply changes immediately
  echo "Applying changes to compositor..."
  hyprctl reload

  # Persistence logic
  echo ""
  gum style --foreground 4 "Should these changes be made permanent?"
  if gum confirm "Persist changes to Flake overrides?"; then
      echo "Saving to overrides..."
      # Attempting to save and save
      if prism-save "$CONFIG_FILE" && prism-save; then
          notify-send "Prism Monitor" "Monitor configuration changed and saved to Flake successfully." -i display
      else
          echo "Error: Failed to save or save changes."
          notify-send "Prism Monitor" "Failed to persist changes. Check logs for permission errors." -u critical
          
          # Hold execution so the user can read the error
          echo "Press any key to exit..."
          read -n 1 -s
          exit 1
      fi
  else
      notify-send "Prism Monitor" "Updated but not saved. These changes will be lost on next startup. Use prism-save to make them permanent." -u normal -i display
  fi

  echo "Operation complete."
  exit 0
''
