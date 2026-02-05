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
      if ! dunstctl is-paused >/dev/null 2>&1; then
           echo "{\"count\": 0, \"icon\": \"\", \"class\": \"empty\", \"dnd\": false}"
           return
      fi

      # Dunst Counters
      WAITING=$(dunstctl count waiting 2>/dev/null || echo 0)
      HISTORY=$(dunstctl count history 2>/dev/null || echo 0)
      PAUSED=$(dunstctl is-paused 2>/dev/null || echo "false")
      
      [[ "$WAITING" =~ ^[0-9]+$ ]] || WAITING=0
      [[ "$HISTORY" =~ ^[0-9]+$ ]] || HISTORY=0
      
      TOTAL=$((WAITING + HISTORY))
      
      # --- ICON LOGIC ---
      
      # 1. If Center is Open (State file exists) -> Show List Icon
      if [ -f "/tmp/prism-notif-state" ]; then
          CLASS="open"
          ICON=""  # List icon
          # We treat it as DND true for styling, but distinct icon
          echo "{\"count\": $TOTAL, \"icon\": \"$ICON\", \"class\": \"$CLASS\", \"dnd\": true}"
          return
      fi

      # 2. If Paused (User DND) -> Show Slashed Bell
      if [ "$PAUSED" == "true" ]; then
          CLASS="dnd"
          ICON=""
      # 3. Normal Active
      elif [ "$TOTAL" -gt 0 ]; then
          CLASS="active"
          ICON=""
      # 4. Empty
      else
          CLASS="empty"
          ICON=""
      fi
      
      echo "{\"count\": $TOTAL, \"icon\": \"$ICON\", \"class\": \"$CLASS\", \"dnd\": $PAUSED}"
  }

  get_status
  while true; do
      sleep 2
      get_status
  done
''
