{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi
    pkgs.libnotify
    # Note: power-profiles-daemon must be installed in system packages/services
  ];
in
writeShellScriptBin "prism-power" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Check if daemon is running
  if ! command -v powerprofilesctl >/dev/null; then
      notify-send "Prism Power" "power-profiles-daemon is not installed or missing from PATH." -u critical
      exit 1
  fi

  # Get current profile
  CURRENT=$(powerprofilesctl get)

  # Options (Icons for flair)
  OPT_PERF="  Performance"
  OPT_BAL="  Balanced"
  OPT_SAVE="  Power Saver"

  # Highlight the active one
  case "$CURRENT" in
    "performance") OPT_PERF="$OPT_PERF (Active)" ;;
    "balanced")    OPT_BAL="$OPT_BAL (Active)" ;;
    "power-saver") OPT_SAVE="$OPT_SAVE (Active)" ;;
  esac

  # Show menu
  SELECTED=$(echo -e "$OPT_PERF\n$OPT_BAL\n$OPT_SAVE" | rofi -dmenu -p "Power Profile")

  case "$SELECTED" in
    *"Performance"*)
      powerprofilesctl set performance
      notify-send "Prism Power" "Profile set to: Performance" -i power-profile-performance
      ;;
    *"Balanced"*)
      powerprofilesctl set balanced
      notify-send "Prism Power" "Profile set to: Balanced" -i power-profile-balanced
      ;;
    *"Power Saver"*)
      powerprofilesctl set power-saver
      notify-send "Prism Power" "Profile set to: Power Saver" -i power-profile-power-saver
      ;;
    *)
      exit 0
      ;;
  esac
''
