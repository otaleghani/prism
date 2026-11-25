{ pkgs }:

pkgs.writeShellApplication {
  name = "prism-present";
  runtimeInputs = with pkgs; [
    coreutils
    util-linux
    dbus
    hyprland
  ];
  text = ''
    if [[ -z "''${WAYLAND_DISPLAY:-}" || -z "''${XDG_RUNTIME_DIR:-}" ]]; then
      echo "Start prism-present from your existing Wayland desktop." >&2
      exit 1
    fi

    outer_runtime="$XDG_RUNTIME_DIR"
    case "$WAYLAND_DISPLAY" in
      /*) ;;
      *) export WAYLAND_DISPLAY="$outer_runtime/$WAYLAND_DISPLAY" ;;
    esac

    # Separate compositor/portal sockets while keeping the existing audio server.
    export PIPEWIRE_RUNTIME_DIR="''${PIPEWIRE_RUNTIME_DIR:-$outer_runtime}"
    export PULSE_SERVER="''${PULSE_SERVER:-unix:$outer_runtime/pulse/native}"
    export XDG_RUNTIME_DIR="$outer_runtime/prism-presentation"
    umask 077
    mkdir -p "$XDG_RUNTIME_DIR"

    # Pin portal activation to the inner socket before Hyprland starts apps.
    # shellcheck disable=SC2016 # $1 belongs to the child shell.
    exec flock --nonblock --close "$XDG_RUNTIME_DIR/session.lock" \
      dbus-run-session -- ${pkgs.runtimeShell} -c '
        dbus-update-activation-environment WAYLAND_DISPLAY=wayland-1 DISPLAY= \
          HYPRLAND_INSTANCE_SIGNATURE= XDG_CURRENT_DESKTOP=Hyprland &&
          exec Hyprland -c "$1"
      ' -- "''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/presentation.lua"
  '';
}
