{
  writeShellScriptBin,
  rofi,
  gawk,
  systemd,
  util-linux,
  gnugrep,
  coreutils,
}:

writeShellScriptBin "prism-portal" ''
  # Dependencies
  # Added gnugrep (for grep), coreutils (for whoami/sleep)
  PATH=${rofi}/bin:${gawk}/bin:${systemd}/bin:${util-linux}/bin:${gnugrep}/bin:${coreutils}/bin:$PATH

  # Get current user
  CURRENT_USER=$(whoami)

  # List available real users
  # Filter logic:
  # - UID >= 1000
  # - Not current user
  # - Not starting with 'nixbld' (Build users)
  # - Not 'nobody'
  TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "'"$CURRENT_USER"'" && $1 !~ /^nixbld/ && $1 != "nobody" {print $1}' /etc/passwd | rofi -dmenu -p "Portal to:")

  [ -z "$TARGET_USER" ] && exit 0

  # Check for active session of target user
  # We look for a session ID associated with the target user
  SESSION_ID=$(loginctl list-sessions | grep "$TARGET_USER" | awk '{print $1}' | head -n 1)

  if [ -n "$SESSION_ID" ]; then
    echo "User $TARGET_USER is active in background (Session $SESSION_ID). Switching..."
    loginctl activate "$SESSION_ID"
    exit 0
  fi

  # If user is NOT active, try to find the Greeter (Login Screen) session
  # SDDM/GDM usually run as a session with class 'greeter' or user 'sddm'/'gdm'
  GREETER_SESSION=$(loginctl list-sessions | grep -E "sddm|gdm|lightdm|greeter" | awk '{print $1}' | head -n 1)

  if [ -n "$GREETER_SESSION" ]; then
    echo "User $TARGET_USER is not logged in. Switching to Greeter (Session $GREETER_SESSION)..."
    loginctl activate "$GREETER_SESSION"
  else
    # Fallback: No Greeter found (it might have exited after login)
    echo "User $TARGET_USER is not logged in and no Greeter session was found."
    echo "You must manually lock the screen or switch TTYs (Ctrl+Alt+F1)."
    
    # We lock the session to be safe, giving the user a chance to switch user from the lockscreen
    # if the lockscreen supports it (most simple lockscreens do not).
    loginctl lock-session
  fi
''
