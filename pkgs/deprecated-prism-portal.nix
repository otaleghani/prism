{
  writeShellScriptBin,
  rofi,
  gawk,
  systemd,
  util-linux,
  coreutils,
}:

writeShellScriptBin "prism-portal" ''
  # Dependencies
  PATH=${rofi}/bin:${gawk}/bin:${systemd}/bin:${util-linux}/bin:${coreutils}/bin:$PATH

  # Get current user
  CURRENT_USER=$(whoami)

  # 1. List available real users
  # Filter out system users, build users, and the current user
  TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "'"$CURRENT_USER"'" && $1 !~ /^nixbld/ && $1 != "nobody" {print $1}' /etc/passwd | rofi -dmenu -p "Portal to:")

  [ -z "$TARGET_USER" ] && exit 0

  # 2. Check for active session of target user
  # We look for an existing session for the target user.
  # loginctl output format: SESSION UID USER SEAT TTY
  SESSION_ID=$(loginctl list-sessions | awk -v u="$TARGET_USER" '$3 == u {print $1}' | head -n 1)

  if [ -n "$SESSION_ID" ]; then
    echo "User $TARGET_USER is active in background (Session $SESSION_ID). Switching..."
    loginctl activate "$SESSION_ID"
    exit 0
  fi

  # 3. New Session Strategy: The "Log Out" Method
  # Since we are using Ly (which doesn't support seamless switching APIs),
  # the cleanest way to start a new session is to log out of the current one.

  CONFIRM=$(echo -e "Yes\nNo" | rofi -dmenu -p "Start session for $TARGET_USER? (This will Log Out)")

  if [ "$CONFIRM" == "Yes" ]; then
      # Exit Hyprland. This returns you to the Ly login screen.
      hyprctl dispatch exit
  fi
''
