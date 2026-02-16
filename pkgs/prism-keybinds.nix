{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.gnugrep
    pkgs.gnused
    pkgs.gawk
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-keybinds" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_DIR="$HOME/.config/hypr"

  # Data collection
  # Recursively scans Hyprland configs for active keybindings
  # Filters out comments and formats the syntax for human readability
  BINDS=$(grep -r "^bind =" "$CONFIG_DIR" | \
    sed 's/.*:bind = //g' | \
    sed 's/$MAIN_MOD/SUPER/g' | \
    sed 's/, exec, /  ->  Exec: /g' | \
    sed 's/, / + /g' | \
    sort)

  # Validation logic
  # Alerts the user if the configuration directory is empty or inaccessible
  if [ -z "$BINDS" ]; then
    notify-send "Prism Keybinds" "No active keybinds detected in $CONFIG_DIR." -u critical
    exit 1
  fi

  # Selection interface
  # Presents the formatted list via an interactive search menu
  echo "$BINDS" | rofi -dmenu -p "Keybinds" -i -width 1000
''
