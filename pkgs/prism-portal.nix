{
  writeShellScriptBin,
  rofi,
  gawk,
  systemd,
  util-linux,
  gnugrep,
  coreutils,
  kbd, # For openvt and chvt
  shadow, # For su
  polkit, # For pkexec
}:

writeShellScriptBin "prism-portal" ''
  # Dependencies
  PATH=${rofi}/bin:${gawk}/bin:${systemd}/bin:${util-linux}/bin:${gnugrep}/bin:${coreutils}/bin:${kbd}/bin:${shadow}/bin:${polkit}/bin:$PATH

  # Get current user
  CURRENT_USER=$(whoami)

  # List available real users
  # Filter out system users, build users, and the current user
  TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "'"$CURRENT_USER"'" && $1 !~ /^nixbld/ && $1 != "nobody" {print $1}' /etc/passwd | rofi -dmenu -p "Portal to:")

  [ -z "$TARGET_USER" ] && exit 0

  # Check for active session of target user
  SESSION_ID=$(loginctl list-sessions | grep "$TARGET_USER" | awk '{print $1}' | head -n 1)

  if [ -n "$SESSION_ID" ]; then
    echo "User $TARGET_USER is active in background (Session $SESSION_ID). Switching..."
    loginctl activate "$SESSION_ID"
    exit 0
  fi

  # Direct Launch (The "Root" Bypass)
  # Since Ly doesn't support switching, and no active session exists,
  # we spawn a NEW session on a NEW TTY manually.

  echo "Launching new session for $TARGET_USER..."

  # pkexec:    Asks for YOUR password (GUI prompt) to get root.
  # openvt:    Finds first available TTY.
  # -s:        Switch to that TTY immediately.
  # --:        End of openvt arguments.
  # su -l:     Login as target user (loads env, doesn't ask password because we are root).
  # -c:        Run the compositor (Hyprland).

  pkexec openvt -s -- su -l "$TARGET_USER" -c "Hyprland"
''
