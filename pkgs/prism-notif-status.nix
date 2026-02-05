{ pkgs, writeShellScriptBin }:
let
  deps = [
    pkgs.jq
    pkgs.coreutils
    pkgs.dunst
    pkgs.gnugrep
    pkgs.procps
  ];
in

writeShellScriptBin "prism-notif-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  get_status() {
      # FIX: Use dunstctl to check status instead of pgrep.
      # pgrep -x "dunst" fails on NixOS because the process is often named ".dunst-wrapped".
      # checking is-paused is a reliable way to see if the daemon is responding.
      if ! dunstctl is-paused >/dev/null 2>&1; then
           echo "{\"count\": 0, \"icon\": \"\", \"class\": \"empty\", \"dnd\": false}"
           return
      fi

      # Dunst waiting = unread notifications on screen
      # Dunst history = past notifications
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
  # Poll every 2 seconds
  while true; do
      sleep 2
      get_status
  done
''
