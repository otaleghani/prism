{ pkgs, writeShellScriptBin }:

writeShellScriptBin "prism-volume" ''
  export PATH=${pkgs.pamixer}/bin:$PATH

  case "$1" in
    "get")
      # Output format: "Volume Muted" (e.g., "45 true" or "80 false")
      echo "$(pamixer --get-volume) $(pamixer --get-mute)"
      ;;
    "up")
      pamixer -i 5
      ;;
    "down")
      pamixer -d 5
      ;;
    "toggle")
      pamixer -t
      ;;
  esac
''
