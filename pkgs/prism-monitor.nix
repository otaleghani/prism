{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.hyprland
    pkgs.coreutils
    pkgs.libnotify
    pkgs.rofi-wayland
  ];
in
writeShellScriptBin "prism-monitor" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_FILE="$HOME/.config/hypr/monitors.conf"

  # Auto-Launch Terminal
  # If this script is run from a keybind (no terminal), it re-launches itself
  # inside a terminal window using prism-tui.
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        # "$0" is the path to this script
        exec prism-tui "$0" "$@"
    else
        notify-send "Prism Monitor" "Error: prism-tui not found." -u critical
        exit 1
    fi
  fi

  # Ensure config exists
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "# Monitor Config" > "$CONFIG_FILE"
    echo "monitor=,preferred,auto,1" >> "$CONFIG_FILE"
  fi

  # Open Editor (Blocking)
  # We use the editor directly (not prism-tui) so the script WAITS for it to close.
  EDITOR="''${EDITOR:-nano}"

  echo "Opening $CONFIG_FILE with $EDITOR..."
  $EDITOR "$CONFIG_FILE"

  # Reload Hyprland
  # This only runs AFTER you close the editor
  echo "Reloading Hyprland configuration..."
  hyprctl reload
  notify-send "Prism Monitor" "Configuration reloaded." -i display

  # Prompt to Persist
  if command -v prism-save >/dev/null; then
      ACTION=$(echo -e "Yes\nNo" | rofi -dmenu -p "Save to Prism Overrides?")
      
      if [ "$ACTION" == "Yes" ]; then
          prism-save "$CONFIG_FILE"
          notify-send "Prism Monitor" "Configuration saved to Flake overrides."
      fi
  fi
''
