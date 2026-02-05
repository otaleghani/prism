{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.socat
    pkgs.jq
    pkgs.hyprland
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-workspaces" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Helper to generate the JSON
  generate() {
    hyprctl workspaces -j | jq -c --argjson active "$(hyprctl monitors -j | jq -r '(.[] | select(.focused == true) | .activeWorkspace.id) // 1')" '
      sort_by(.id) | map({
        id: .id, 
        active: (.id == $active),
        windows: .windows
      })
    '
  }

  # 1. Output initial state
  generate

  # 2. Listen to socket for changes
  # We listen for workspace/monitor events and regenerate JSON
  socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    case "$line" in
      workspace*|createworkspace*|destroyworkspace*|movewindow*)
        generate
        ;;
    esac
  done
''
