{
  writeShellScriptBin,
}:

writeShellScriptBin "prism-session" ''
  # Usage: prism-session [lock|logout|suspend|reboot|shutdown]

  case "$1" in
    "lock")
        loginctl lock-session
        ;;
    "logout")
        # Kill user processes to ensure clean exit
        pkill -u "$USER"
        # Hyprland specific exit
        hyprctl dispatch exit
        ;;
    "suspend")
        systemctl suspend
        ;;
    "reboot")
        systemctl reboot
        ;;
    "shutdown")
        systemctl poweroff
        ;;
    *)
        echo "Usage: prism-session [lock|logout|suspend|reboot|shutdown]"
        exit 1
        ;;
  esac
''
