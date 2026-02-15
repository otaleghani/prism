{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.findutils
    pkgs.gnused
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-game-launcher" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Scan standard Linux application paths for Game entries
  APP_DIRS=("/run/current-system/sw/share/applications" "$HOME/.local/share/applications")

  # Find all desktop files that contain "Categories=.*Game"
  GAMES=$(grep -rl "Categories=.*Game" "''${APP_DIRS[@]}" 2>/dev/null | xargs -n1 basename | sed 's/\.desktop//' | sort -u)

  if [ -z "$GAMES" ]; then
    notify-send "Prism Gamer" "No games detected in your application folders."
    exit 1
  fi

  SELECTED=$(echo "$GAMES" | rofi -dmenu -p "🕹️ Launch Game" -config "$HOME/.config/rofi/config.rasi")

  if [ -n "$SELECTED" ]; then
    # Launch the desktop file via gtk-launch or dex
    gtk-launch "$SELECTED"
  fi
''
