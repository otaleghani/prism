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
}:

writeShellScriptBin "prism-portal" ''
  # Dependencies
  PATH=${rofi}/bin:${gawk}/bin:${systemd}/bin:${util-linux}/bin:${gnugrep}/bin:${coreutils}/bin:${kbd}/bin:${shadow}/bin:$PATH

  # Get current user
  CURRENT_USER=$(whoami)

  # 1. List available real users
  # Filter out system users, build users, and the current user
  TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "'"$CURRENT_USER"'" && $1 !~ /^nixbld/ && $1 != "nobody" {print $1}' /etc/passwd | rofi -dmenu -p "Portal to:")

  [ -z "$TARGET_USER" ] && exit 0

  # 2. Check for active session of target user
  SESSION_ID=$(loginctl list-sessions | grep "$TARGET_USER" | awk '{print $1}' | head -n 1)

  if [ -n "$SESSION_ID" ]; then
    echo "User $TARGET_USER is active in background (Session $SESSION_ID). Switching..."
    loginctl activate "$SESSION_ID"
    exit 0
  fi

  # 3. Direct Launch (The "Root" Bypass)

  # Improve prompt clarity
  PASSWORD=$(rofi -dmenu -password -p "Portal Authorization:" -lines 0)

  # If user cancelled (empty password), exit
  if [ -z "$PASSWORD" ]; then
    exit 1
  fi

  echo "Launching new session for $TARGET_USER..."

  # Get User ID and Group ID for the target user
  TARGET_UID=$(id -u "$TARGET_USER")
  TARGET_GID=$(id -g "$TARGET_USER")

  # The runtime directory required by Wayland/Hyprland
  RUNTIME_DIR="/run/user/$TARGET_UID"

  # Construct the startup command
  # 1. Setup Runtime Dir (Root)
  # 2. openvt: Open a new Virtual Terminal
  # 3. Inside openvt (as Root):
  #    a. chown the TTY device to the target user (Crucial for GPU access!)
  #    b. su to target user
  #    c. Create .cache dir (Fixes crash report error)
  #    d. Launch Hyprland

  CMD="
    mkdir -p $RUNTIME_DIR
    chown $TARGET_UID:$TARGET_GID $RUNTIME_DIR
    chmod 700 $RUNTIME_DIR
    
    openvt -s -- bash -c '
      chown $TARGET_UID:$TARGET_GID \$(tty); 
      chmod 600 \$(tty);
      su -l $TARGET_USER -c \"export XDG_RUNTIME_DIR=$RUNTIME_DIR; mkdir -p \$HOME/.cache; Hyprland\"
    '
  "

  # Execute with sudo, passing the password via stdin
  echo "$PASSWORD" | sudo -S bash -c "$CMD" 2>/dev/null
''
