# prism-active-window returns the name of the current active window in hyprland

{ pkgs, writeShellScriptBin }:
let
  deps = [
    pkgs.socat
    pkgs.jq
    pkgs.hyprland
    pkgs.coreutils
  ];
in

writeShellScriptBin "prism-active-window" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH
  # Initial
  hyprctl activewindow -j | jq --unbuffered -r '.title // "..."'

  # Listen
  socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    case "$line" in
      activewindow*)
        hyprctl activewindow -j | jq --unbuffered -r '.title // "..."'
        ;;
    esac
  done
''
