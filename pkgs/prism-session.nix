{
  writeShellScriptBin,
  rofi,
  systemd,
  procps, # for pkill
}:

writeShellScriptBin "prism-session" ''
  export PATH=${rofi}/bin:${systemd}/bin:${procps}/bin:$PATH

  # Options
  logout="󰗽  Logout (Disconnect)"
  lock="  Lock"
  suspend="󰤄  Suspend"
  reboot="  Reboot"
  shutdown="  Shutdown"

  # Rofi Command
  # --dmenu: Reads from stdin
  # --placeholder: Sets the text in the search bar
  selected_option=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi -dmenu -p "session" -theme ~/.config/rofi/session.rasi)

  case "$selected_option" in
    "$logout")
      # Ignore signals in this scripts
      trap "" HUP INT TERM
      # Kill deamons that might hand onto the old Wayland session
      pkill ghostty || true
      sleep 0.1
      # This kills Hyprland, dropping you back to the login screen
      hyprctl dispatch exit
      ;;
    "$lock")
      # Locks the screen
      loginctl lock-session
      ;;
    "$suspend")
      systemctl suspend
      ;;
    "$reboot")
      systemctl reboot
      ;;
    "$shutdown")
      systemctl poweroff
      ;;
    *)
      # Do nothing if cancelled
      ;;
  esac
''
