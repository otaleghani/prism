{
  writeShellScriptBin,
  walker,
  systemd,
  procps, # for pkill
}:

writeShellScriptBin "prism-session" ''
  export PATH=${walker}/bin:${systemd}/bin:${procps}/bin:$PATH

  # Options
  logout="󰗽  Logout (Disconnect)"
  lock="  Lock"
  suspend="󰤄  Suspend"
  reboot="  Reboot"
  shutdown="  Shutdown"

  # Walker Command
  # --dmenu: Reads from stdin
  # --placeholder: Sets the text in the search bar
  selected_option=$(echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | walker --dmenu --placeholder "Session")

  case "$selected_option" in
    "$logout")
      # This kills Hyprland, dropping you back to Ly (Login Screen)
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
