{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.gum
    pkgs.glib # for gsettings
    pkgs.fontconfig # for fc-list
    pkgs.coreutils
    pkgs.gnused
  ];
in
writeShellScriptBin "prism-font" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # 1. Get a list of unique System Fonts
  # fc-list : family gets the names, cut/sort cleans it up
  FONTS=$(fc-list : family | cut -d',' -f1 | sort -u)

  # 2. Select Font Family via Rofi
  SELECTED_FONT=$(echo "$FONTS" | rofi -dmenu -p "System Font")

  if [ -z "$SELECTED_FONT" ]; then
    exit 0
  fi

  # 3. Select Font Size via Gum
  FONT_SIZE=$(gum input --placeholder "11" --header "Enter Font Size (e.g., 10, 11, 12)")

  if [ -z "$FONT_SIZE" ]; then
    FONT_SIZE="11" # Default fallback
  fi

  FULL_FONT_STRING="$SELECTED_FONT $FONT_SIZE"

  # 4. Apply via GSettings (GTK Apps)
  echo "[Prism] Applying font: $FULL_FONT_STRING"

  gsettings set org.gnome.desktop.interface font-name "$FULL_FONT_STRING"
  gsettings set org.gnome.desktop.interface document-font-name "$FULL_FONT_STRING"

  # Optional: Update Monospace font if you want it to affect terminals/editors
  if gum confirm "Would you like to set this as the Monospace font too?"; then
      gsettings set org.gnome.desktop.interface monospace-font-name "$FULL_FONT_STRING"
  fi

  notify-send "Prism" "System font updated to $FULL_FONT_STRING" -i preferences-desktop-font
''
