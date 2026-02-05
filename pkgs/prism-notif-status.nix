{ pkgs, writeShellScriptBin }:
let
  deps = [
    pkgs.jq
    pkgs.coreutils
    pkgs.swaynotificationcenter
    pkgs.gnugrep
    pkgs.procps
  ];
in

writeShellScriptBin "prism-notif-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  get_status() {
      # Check if dunst is running first to avoid errors
      if ! pgrep -x "dunst" >/dev/null; then
           echo "{\"count\": 0, \"icon\": \"\", \"class\": \"empty\", \"dnd\": false}"
           return
      fi

      # Dunst waiting = unread notifications on screen
      # Dunst history = past notifications
      # We use || echo 0 to prevent script crash if dunstctl fails or returns empty
      WAITING=$(dunstctl count waiting 2>/dev/null || echo 0)
      HISTORY=$(dunstctl count history 2>/dev/null || echo 0)
      PAUSED=$(dunstctl is-paused 2>/dev/null || echo "false")
      
      # Ensure values are integers
      [[ "$WAITING" =~ ^[0-9]+$ ]] || WAITING=0
      [[ "$HISTORY" =~ ^[0-9]+$ ]] || HISTORY=0
      
      TOTAL=$((WAITING + HISTORY))
      
      if [ "$PAUSED" == "true" ]; then
          CLASS="dnd"
          ICON=""
      elif [ "$TOTAL" -gt 0 ]; then
          CLASS="active"
          ICON=""
      else
          CLASS="empty"
          ICON=""
      fi
      
      echo "{\"count\": $TOTAL, \"icon\": \"$ICON\", \"class\": \"$CLASS\", \"dnd\": $PAUSED}"
  }

  get_status
  # There isn't a clean 'dunstctl subscribe' for count changes like SwayNC.
  # We must poll efficiently.
  while true; do
      sleep 2
      get_status
  done
''
