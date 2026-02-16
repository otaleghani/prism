{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.hyprland
    pkgs.gnused
    pkgs.libnotify
    pkgs.gawk
    pkgs.xorg.xkeyboardconfig
  ];
in
writeShellScriptBin "prism-keyboard" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_FILE="$HOME/.config/hypr/input.conf"
  XKB_BASE="${pkgs.xorg.xkeyboardconfig}/share/X11/xkb/rules/base.lst"

  # Data collection
  # Parses the X11 keyboard database to extract valid layout codes and descriptions
  if [ -f "$XKB_BASE" ]; then
      LAYOUTS=$(awk '
        BEGIN { recording=0 }
        /^! layout/ { recording=1; next }
        /^!/ { recording=0 }
        recording && $0 != "" { 
            code=$1; 
            $1=""; 
            print code " " $0 
        }
      ' "$XKB_BASE")
  else
      # Manual fallback for common regional layouts
      LAYOUTS="us - English (US)\nit - Italian\nde - German\nfr - French\nes - Spanish\nuk - English (UK)\npt - Portuguese\nru - Russian\njp - Japanese"
  fi

  # Selection interface
  # Presents the full list via rofi for fuzzy searching by name or code
  SELECTED_LINE=$(echo "$LAYOUTS" | rofi -dmenu -p "Keyboard Layout" -i)

  if [ -z "$SELECTED_LINE" ]; then exit 0; fi

  # Extraction logic
  # Isolates the specific country/language code for the system command
  SELECTED=$(echo "$SELECTED_LINE" | awk '{print $1}')

  # Persistence logic
  # Updates the local configuration file for persistence across reboots
  if [ -f "$CONFIG_FILE" ]; then
      sed -i "s/kb_layout = .*/kb_layout = $SELECTED/" "$CONFIG_FILE" || {
        notify-send "Prism Keyboard" "Failed to update configuration file." -u critical
        exit 1
      }
  fi

  # Hardware application
  # Triggers an immediate layout switch in the active compositor
  hyprctl keyword input:kb_layout "$SELECTED" || {
    notify-send "Prism Keyboard" "Failed to apply layout to active session." -u critical
    exit 1
  }

  # Success feedback
  notify-send "Prism" "Keyboard layout set to: $SELECTED" -i input-keyboard
''
