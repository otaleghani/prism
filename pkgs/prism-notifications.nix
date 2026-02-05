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
         # FIX: Removed the double loop to prevent duplication.
         # FIX: Added '| reverse' so newest notifications are at the top.
         # We use '|| echo []' to handle cases where history might be empty or malformed.
         HISTORY=$(dunstctl history 2>/dev/null)
         
         if [ -n "$HISTORY" ]; then
             echo "$HISTORY" | jq -c '[.data[][] | {
               id: .id.data, 
               app: .appname.data, 
               summary: .summary.data, 
               body: .body.data,
               urgency: .urgency.data,
               time: .timestamp.data,
               actions: (if .actions.data then [.actions.data | range(0; length; 2) as $i | {id: .[$i], label: .[$i+1]}] else [] end)
             }] | reverse'
         else
             echo "[]"
         fi
      }
      
      # Initial update
      update
      
      # Trap SIGUSR1 to force a manual refresh (used by 'clear' / 'dismiss' commands)
      # This allows instant UI updates when you click buttons, despite the polling delay.
      trap update SIGUSR1
      
      # POLLING LOOP
      # Since 'dunstctl subscribe' is unavailable, we poll history every second.
      while true; do
        sleep 1
        update
      done
      ;;
      
    "dismiss")
      # Close specific ID if active
      dunstctl close "$2"
      
      # Remove from history
      dunstctl history-rm "$2"
      
      # Force refresh immediately so UI updates
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
