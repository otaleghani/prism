{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.jq
    pkgs.coreutils
    pkgs.dunst
    pkgs.gnugrep
    pkgs.procps
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-notif-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Status generation
  # Aggregates displayed, waiting, and history counts into a JSON object
  get_status() {
      # Verify daemon responsiveness
      if ! dunstctl is-paused >/dev/null 2>&1; then
           echo "{\"count\": 0, \"icon\": \"\", \"class\": \"empty\", \"dnd\": false}"
           return
      fi

      # Data collection
      # Retrieves counters for various notification states
      DISPLAYED=$(dunstctl count displayed 2>/dev/null || echo 0)
      WAITING=$(dunstctl count waiting 2>/dev/null || echo 0)
      HISTORY=$(dunstctl count history 2>/dev/null || echo 0)
      PAUSED=$(dunstctl is-paused 2>/dev/null || echo "false")
      
      # Sanitization
      # Ensures numeric values for arithmetic operations
      [[ "$DISPLAYED" =~ ^[0-9]+$ ]] || DISPLAYED=0
      [[ "$WAITING" =~ ^[0-9]+$ ]] || WAITING=0
      [[ "$HISTORY" =~ ^[0-9]+$ ]] || HISTORY=0
      
      TOTAL=$((DISPLAYED + WAITING + HISTORY))
      
      # Icon logic
      # Determines visual state based on DND status and message count
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

  # Initial execution
  get_status || {
    notify-send "Prism Status" "Notification tracker failed to initialize." -u critical
    exit 1
  }

  # Update loop
  # Continuously provides state updates for the UI panel
  while true; do
      sleep 2
      get_status
  done
''
