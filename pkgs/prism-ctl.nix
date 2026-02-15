{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-ctl" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Usage: prism-drawer <target>
  TARGET="$1"

  if [ -z "$TARGET" ]; then
    echo "Usage: prism-drawer [calendar|mixer|notifications|wallpapers|themes|brightness|session]"
    exit 1
  fi

  case "$TARGET" in
    "calendar")
      touch /tmp/prism-drawer-calendar
      ;;
    "mixer")
      touch /tmp/prism-drawer-volume
      ;;
    "notifications")
      touch /tmp/prism-drawer-notifications
      ;;
    "wallpapers")
      touch /tmp/prism-drawer-wallpapers
      ;;
    "themes")
      touch /tmp/prism-drawer-themes
      ;;
    "brightness")
      touch /tmp/prism-drawer-brightness
      ;;
    "session")
      touch /tmp/prism-session
      ;;
    "sidebar")
      touch /tmp/prism-sidebar
      ;;
    *)
      echo "Error: Unknown drawer '$TARGET'"
      exit 1
      ;;
  esac
''
