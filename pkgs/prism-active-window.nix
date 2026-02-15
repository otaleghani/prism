{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.socat
    pkgs.jq
    pkgs.hyprland
    pkgs.coreutils
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-active-window" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Dependency check
  if ! command -v hyprctl >/dev/null; then
    notify-send "Prism Window Tracker" "Compositor not detected. This script requires Hyprland." -u critical
    exit 1
  fi

  # State generation
  get_title() {
    hyprctl activewindow -j | jq --unbuffered -r '.title // "..."'
  }

  # Initial output
  get_title

  # Event listener
  # Connects to the Hyprland socket to react instantly to window changes
  socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    case "$line" in
      activewindow*)
        get_title
        ;;
    esac
  done || {
    notify-send "Prism Window Tracker" "Socket connection lost. Restarting background process."
    # Wait for user input if run interactively to debug crash
    if [ -t 0 ]; then
        echo "Stream interrupted. Press any key to exit..."
        read -n 1 -s
    fi
  }
''
