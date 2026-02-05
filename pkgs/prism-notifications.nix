{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.dunst
    pkgs.jq
    pkgs.coreutils
    pkgs.gnugrep
  ];
in
writeShellScriptBin "prism-notifications" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH
      
      get_status() {
          # Dunst waiting = unread notifications on screen
          # Dunst history = past notifications
          WAITING=$(dunstctl count waiting)
          HISTORY=$(dunstctl count history)
          PAUSED=$(dunstctl is-paused)
          
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
      # We must poll efficiently or hook into the history changes script.
      # For now, a 2s poll is lightweight enough for this specific status.
      while true; do
          get_status
          sleep 2
      done
''
