{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.hyprland
    pkgs.coreutils
    pkgs.libnotify
    pkgs.rofi # For the Yes/No prompt
  ];
in
writeShellScriptBin "prism-monitor" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_FILE="$HOME/.config/hypr/monitors.conf"

  # Ensure config exists
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "# Monitor Config" > "$CONFIG_FILE"
    echo "monitor=,preferred,auto,1" >> "$CONFIG_FILE"
  fi

  # Open Editor
  # Uses EDITOR env var, falls back to nano
  EDITOR="${"EDITOR:-nano"}"

  echo "Opening $CONFIG_FILE with $EDITOR..."
  prism-tui $EDITOR "$CONFIG_FILE"

  # Reload Hyprland
  echo "Reloading Hyprland configuration..."
  hyprctl reload
  notify-send "Prism Monitor" "Configuration reloaded." -i display

  # Prompt to Persist
  # We check if prism-save exists before asking
  if command -v prism-save >/dev/null; then
      ACTION=$(echo -e "Yes\nNo" | rofi -dmenu -p "Save to Prism Overrides?")
      
      if [ "$ACTION" == "Yes" ]; then
          prism-save "$CONFIG_FILE"
          notify-send "Prism Monitor" "Configuration saved to Flake overrides."
      fi
  fi
''
