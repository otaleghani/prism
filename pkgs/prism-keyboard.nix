{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi-wayland
    pkgs.hyprland
    pkgs.gnused
    pkgs.libnotify
    pkgs.gawk
    pkgs.xorg.xkeyboardconfig # Contains the master list of layouts
  ];
in
writeShellScriptBin "prism-keyboard" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_FILE="$HOME/.config/hypr/input.conf"

  # Locate the XKB rules file provided by Nix
  # This file contains the list of all valid keyboard layouts and their descriptions
  XKB_BASE="${pkgs.xorg.xkeyboardconfig}/share/X11/xkb/rules/base.lst"

  # Parse the available layouts
  if [ -f "$XKB_BASE" ]; then
      # awk logic:
      # 1. Find the '! layout' section
      # 2. Print columns: Code - Description
      # 3. Stop when we hit the next section (starting with !)
      LAYOUTS=$(awk '
        BEGIN { recording=0 }
        /^! layout/ { recording=1; next }
        /^!/ { recording=0 }
        recording && $0 != "" { 
            # $1 is the code (e.g., "us"), rest is description
            code=$1; 
            $1=""; 
            print code " " $0 
        }
      ' "$XKB_BASE")
  else
      # Fallback if something goes wrong with the package
      LAYOUTS="us - English (US)\nit - Italian\nde - German\nfr - French\nes - Spanish\nuk - English (UK)\npt - Portuguese\nru - Russian\njp - Japanese"
  fi

  # Select Layout
  # We show the full description in Rofi for easier searching (e.g., "English")
  SELECTED_LINE=$(echo "$LAYOUTS" | rofi -dmenu -p "Keyboard Layout" -i)

  if [ -z "$SELECTED_LINE" ]; then exit 0; fi

  # Extract just the code (the first word, e.g., "us" or "de")
  SELECTED=$(echo "$SELECTED_LINE" | awk '{print $1}')

  # Update config file
  if [ -f "$CONFIG_FILE" ]; then
      sed -i "s/kb_layout = .*/kb_layout = $SELECTED/" "$CONFIG_FILE"
  fi

  # Apply instantly
  hyprctl keyword input:kb_layout "$SELECTED"

  notify-send "Prism" "Keyboard layout set to: $SELECTED" -i input-keyboard
''
