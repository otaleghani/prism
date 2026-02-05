{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.dunst
    pkgs.jq
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.procps
  ];
in
writeShellScriptBin "prism-notifications" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CMD="$1"
  STATE_FILE="/tmp/prism-notif-state"

  case "$CMD" in
    "listen")
      update() {
         dunstctl history | jq -c '[.data[][].id.data as $id | .data[][] | {
           id: $id, 
           app: .appname.data, 
           summary: .summary.data, 
           body: .body.data,
           urgency: .urgency.data,
           time: .timestamp.data,
           actions: (if .actions.data then [.actions.data | range(0; length; 2) as $i | {id: .[$i], label: .[$i+1]}] else [] end)
         }]'
      }
      
      update
      trap update SIGUSR1
      
      (
        dunstctl subscribe | grep --line-buffered -E "notification|removed" | while read -r _; do
          update
        done
      ) &
      
      while true; do wait; done
      ;;
      
    "dismiss")
      dunstctl close "$2"
      dunstctl history-rm "$2"
      pkill -SIGUSR1 -f "prism-notifications listen"
      ;;
      
    "clear")
      dunstctl close-all
      dunstctl history-clear
      pkill -SIGUSR1 -f "prism-notifications listen"
      ;;
      
    "action")
      ACTION_ID="''${3:-default}"
      dunstctl action "$2" "$ACTION_ID"
      ;;

    "toggle-center")
      STATE="$2"
      
      if [ "$STATE" == "open" ]; then
          # 1. Save current state
          IS_PAUSED=$(dunstctl is-paused)
          echo "$IS_PAUSED" > "$STATE_FILE"

          # 2. Pause and clear screen
          dunstctl set-paused true
          dunstctl close-all
      else
          # 3. Restore previous state
          if [ -f "$STATE_FILE" ]; then
              WAS_PAUSED=$(cat "$STATE_FILE")
              if [ "$WAS_PAUSED" == "false" ]; then
                  dunstctl set-paused false
              fi
              # FIX: Delete the state file so we know the center is closed
              rm "$STATE_FILE"
          else
              dunstctl set-paused false
          fi
      fi
      ;;
  esac
''
