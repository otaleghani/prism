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

  case "$CMD" in
    "listen")
      update() {
         # Dump history as JSON for Eww
         # FIX: Removed the double loop (.id.data as $id) that caused duplication.
         # Added '| reverse' so the newest notifications appear at the top.
         dunstctl history | jq -c '[.data[][] | {
           id: .id.data, 
           app: .appname.data, 
           summary: .summary.data, 
           body: .body.data,
           urgency: .urgency.data,
           time: .timestamp.data,
           actions: (if .actions.data then [.actions.data | range(0; length; 2) as $i | {id: .[$i], label: .[$i+1]}] else [] end)
         }] | reverse'
      }
      
      # Initial update
      update
      
      # Trap SIGUSR1 to force a manual refresh (used by 'clear' command)
      trap update SIGUSR1
      
      # Subscribe to events in background
      (
        dunstctl subscribe | grep --line-buffered -E "notification|removed" | while read -r _; do
          update
        done
      ) &
      
      # Wait loop
      while true; do
        wait
      done
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
  esac
''
