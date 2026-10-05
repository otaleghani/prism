{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.hyprland
    pkgs.jq
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-keybinds" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Query loaded bindings so Lua-generated bindings appear and old/ stays ignored.
  BINDS=$(hyprctl binds -j | jq -r '
    sort_by(.modmask, .key, .description)[] |
    . as $bind |
    ([{bit: 64, name: "SUPER"}, {bit: 4, name: "CTRL"},
      {bit: 8, name: "ALT"}, {bit: 1, name: "SHIFT"},
      {bit: 2, name: "CAPS"}, {bit: 16, name: "MOD2"},
      {bit: 32, name: "MOD3"}, {bit: 128, name: "MOD5"}] |
      map(select(($bind.modmask / .bit | floor) % 2 == 1) | .name)
      + [if $bind.key != "" then $bind.key else "code:\($bind.keycode)" end] |
      join(" + ")) + "  ->  " +
    (if .description != "" then .description else .dispatcher + " " + .arg end)
  ')

  # Validation logic
  # Alerts the user if the compositor has no bindings or is inaccessible
  if [ -z "$BINDS" ]; then
    notify-send "Prism Keybinds" "No active Hyprland keybinds detected." -u critical
    exit 1
  fi

  # Selection interface
  # Presents the formatted list via an interactive search menu
  echo "$BINDS" | rofi -dmenu -p "Keybinds" -i -width 1000
''
