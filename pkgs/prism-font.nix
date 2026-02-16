{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.fzf
    pkgs.gum
    pkgs.glib
    pkgs.fontconfig
    pkgs.coreutils
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-font" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Terminal auto-launch
  if [ ! -t 0 ]; then
    if command -v prism-tui >/dev/null; then
        exec prism-tui "$0" "$@"
    else
        notify-send "Prism Appearance" "Terminal wrapper not found." -u critical
        exit 1
    fi
  fi

  # Header display
  clear
  gum style --border double --margin "1 2" --padding "1 2" --foreground 5 "Prism Font Manager"

  # Font discovery
  # Queries system font database for unique family names
  FONTS=$(fc-list : family | cut -d',' -f1 | sort -u)

  # Family selection
  # High-performance filtering via fzf
  SELECTED_FONT=$(echo "$FONTS" | fzf \
    --prompt="Font Family> " \
    --height=40% \
    --layout=reverse \
    --border \
    --header="Select System Font")

  [ -z "$SELECTED_FONT" ] && exit 0

  # Size selection
  # Interactive numeric input via gum
  FONT_SIZE=$(gum input --placeholder "11" --header "Enter Font Size (e.g. 10, 12, 14)")
  FONT_SIZE="''${FONT_SIZE:-11}"

  FULL_FONT_STRING="$SELECTED_FONT $FONT_SIZE"

  # Application logic
  # Pushes font configuration to GTK and system schemas
  echo "Applying $FULL_FONT_STRING..."

  gsettings set org.gnome.desktop.interface font-name "$FULL_FONT_STRING" && \
  gsettings set org.gnome.desktop.interface document-font-name "$FULL_FONT_STRING" || {
      notify-send "Prism Appearance" "Failed to update system fonts." -u critical
      exit 1
  }

  # Monospace toggle
  echo ""
  if gum confirm "Set this as the system Monospace font too?"; then
      gsettings set org.gnome.desktop.interface monospace-font-name "$FULL_FONT_STRING"
  fi

  # Success feedback
  notify-send "Prism Appearance" "System font updated to $FULL_FONT_STRING" -i preferences-desktop-font
''
