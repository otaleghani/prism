{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.rofi-wayland
    pkgs.systemd # for timedatectl
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-timezone" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Get List of zones
  # timedatectl list-timezones gives a huge list (Europe/Rome, America/New_York...)
  ZONES=$(timedatectl list-timezones)

  # Select zone
  SELECTED=$(echo "$ZONES" | rofi -dmenu -p "Timezone")

  if [ -z "$SELECTED" ]; then exit 0; fi

  # Apply
  # timedatectl handles the permission prompt automatically via Polkit
  if timedatectl set-timezone "$SELECTED"; then
      notify-send "Prism" "Timezone set to: $SELECTED" -i preferences-system-time
  else
      notify-send "Prism" "Failed to set timezone" -u critical
  fi
''
