{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.hyprland
    pkgs.coreutils
    pkgs.libnotify
    pkgs.rofi
    pkgs.neovim
  ];
in
writeShellScriptBin "prism-monitor" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_FILE="$HOME/.config/hypr/monitors.conf"

  # Terminal auto-launch
  # If launched from a keybind, re-run inside the Prism TUI wrapper
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        exec prism-tui "$0" "$@"
    else
        notify-send "Prism Monitor" "Error: prism-tui not found." -u critical
        exit 1
    fi
  fi

  # Ensure config exists
  if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "# Prism Monitor Configuration" > "$CONFIG_FILE"
    echo "# monitor=name,resolution,position,scale" >> "$CONFIG_FILE"
    echo "monitor=,preferred,auto,1" >> "$CONFIG_FILE"
  fi

  # Dynamic editor selection
  # Uses the inherited $EDITOR variable from your Hyprland env setup
  # Defaults to nvim if $EDITOR is unset.
  EDITOR_CMD="''${EDITOR:-nvim}"

  clear
  echo "[Prism] Opening Monitor Layout with $EDITOR_CMD..."
  $EDITOR_CMD "$CONFIG_FILE"

  # Apply changes immediately
  hyprctl reload

  # Persistence logic
  SAVE_ACTION=$(echo -e "Yes\nNo" | rofi -dmenu -p "Persist changes to Flake?")

  if [ "$SAVE_ACTION" == "Yes" ]; then
      echo "[Prism] Saving to overrides..."
      # Run prism-save then prism-sync as requested
      if prism-save "$CONFIG_FILE" && prism-sync; then
          notify-send "Prism Monitor" "Monitor config changed and saved to Flake." -i display
      else
          notify-send "Prism Monitor" "Failed to persist changes." -u critical
      fi
  else

      # Custom notification for the "No" branch
      notify-send "Prism Monitor" "Updated but not saved, this will be overridden next startup. If you wish to make it permanent, use prism-save." -u normal -i display
  fi

  exit 0
''
