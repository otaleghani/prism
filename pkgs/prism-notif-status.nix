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
      # displayed: currently shown as popup
      # waiting: queued/unread
      # history: past notifications
      DISPLAYED=$(dunstctl count displayed 2>/dev/null || echo 0)
      WAITING=$(dunstctl count waiting 2>/dev/null || echo 0)
      HISTORY=$(dunstctl count history 2>/dev/null || echo 0)
      PAUSED=$(dunstctl is-paused 2>/dev/null || echo "false")
      
      [[ "$DISPLAYED" =~ ^[0-9]+$ ]] || DISPLAYED=0
      [[ "$WAITING" =~ ^[0-9]+$ ]] || WAITING=0
      [[ "$HISTORY" =~ ^[0-9]+$ ]] || HISTORY=0
      
      TOTAL=$((DISPLAYED + WAITING + HISTORY))
      
      # --- ICON LOGIC ---

      # 1. If Paused (User DND) -> Show Slashed Bell
      if [ "$PAUSED" == "true" ]; then
          CLASS="dnd"
          ICON=""
      # 2. Normal Active
      elif [ "$TOTAL" -gt 0 ]; then
          CLASS="active"
          ICON=""
      # 3. Empty
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
