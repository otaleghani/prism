{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi-wayland
    pkgs.gnugrep
    pkgs.gnused
    pkgs.gawk
  ];
in
writeShellScriptBin "prism-keybinds" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CONFIG_DIR="$HOME/.config/hypr"

  # Gather keybinds
  # We look recursively (-r) in the hypr folder for lines starting with 'bind ='
  # We exclude comments (#)
  # We prettify the output:
  #   - Remove 'bind = '
  #   - Replace $mainMod with SUPER
  #   - Format nicely

  BINDS=$(grep -r "^bind =" "$CONFIG_DIR" | \
    sed 's/.*:bind = //g' | \
    sed 's/$mainMod/SUPER/g' | \
    sed 's/, exec, /  ->  Exec: /g' | \
    sed 's/, / + /g' | \
    sort)

  if [ -z "$BINDS" ]; then
    rofi -e "No keybinds found in $CONFIG_DIR"
    exit 1
  fi

  # Show menu
  # -i: Case insensitive
  # -p: Prompt
  echo "$BINDS" | rofi -dmenu -p "Keybinds" -i -width 1000
''
