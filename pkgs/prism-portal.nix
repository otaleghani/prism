{
  writeShellScriptBin,
  rofi,
  gawk,
  systemd,
  util-linux,
}:

writeShellScriptBin "prism-portal" ''
  # Dependencies
  PATH=${rofi}/bin:${gawk}/bin:${systemd}/bin:${util-linux}/bin:$PATH

  # Get current user
  CURRENT_USER=$(whoami)

  # List available real users (UID >= 1000) excluding current one
  # Format: "dev" or "gamer"
  TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "'"$CURRENT_USER"'" {print $1}' /etc/passwd | rofi -dmenu -p "Portal to:")

  [ -z "$TARGET_USER" ] && exit 0

  # Check for active session
  SESSION_ID=$(loginctl list-sessions | grep "$TARGET_USER" | awk '{print $1}')

  if [ -n "$SESSION_ID" ]; then
    echo "User $TARGET_USER is active in background. Switching..."
    loginctl activate "$SESSION_ID"
  else
    echo "User $TARGET_USER is not logged in. Redirecting to Greeter..."
    # Locking the current session usually forces the display manager to show the login screen
    loginctl lock-session
    
    # Alternatively, if using GDM, you could try:
    # gdmflexiserver
  fi
''
