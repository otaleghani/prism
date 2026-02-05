{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.dunst
    pkgs.jq
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.procps # Added for pkill
  ];
in
writeShellScriptBin "prism-notifications" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CMD="$1"

  case "$CMD" in
    "listen")
      update() {
         # Dump history as JSON for Eww
         dunstctl history | jq -c '[.data[][].id.data as $id | .data[][] | {
           id: $id, 
           app: .appname.data, 
           summary: .summary.data, 
           body: .body.data,
           urgency: .urgency.data,
           time: .timestamp.data
         }]'
      }
      
      # Initial update
      update
      
      # Trap SIGUSR1 to force a manual refresh (used by 'clear' command)
      trap update SIGUSR1
      
      # Subscribe to events in background
      # We listen for 'notification' (new) and 'removed' (closed) events.
      # This ensures the list updates instantly when popups close.
      (
        dunstctl subscribe | grep --line-buffered -E "notification|removed" | while read -r _; do
          update
        done
      ) &
      
      # Wait keeps the script running so it can receive signals
      wait
      ;;
      
    "dismiss")
      # Close specific ID if active
      dunstctl close "$2"
      
      # Remove from history (Supported in newer Dunst versions)
      dunstctl history-rm "$2"
      
      # Force refresh immediately so UI updates
      pkill -SIGUSR1 -f "prism-notifications listen"
      ;;
      
    "clear")
      # Close all active popups
      dunstctl close-all
      # Clear the internal history
      dunstctl history-clear
      # Signal the listener (running in Eww) to refresh the list immediately
      pkill -SIGUSR1 -f "prism-notifications listen"
      ;;
      
    "action")
      dunstctl action "$2"
      ;;
  esac
''
