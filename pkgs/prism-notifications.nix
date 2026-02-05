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
         # We extract actions to allow interactive buttons
         # Dunst actions are stored as a flat array: [id, label, id, label...]
         # We use jq to pair them up into objects: {id: "default", label: "Open"}
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
      
      # Initial update
      update
      
      # Trap SIGUSR1 to force a manual refresh (used by 'clear' command)
      trap update SIGUSR1
      
      # Subscribe to events in background
      # We listen for 'notification' (new) and 'removed' (closed) events.
      (
        dunstctl subscribe | grep --line-buffered -E "notification|removed" | while read -r _; do
          update
        done
      ) &
      
      # Wait loop to keep script running and handling signals
      while true; do
        wait
      done
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
      # Trigger an action (default or specific)
      # $2 = Notification ID, $3 = Action ID (optional, defaults to 'default')
      ACTION_ID="''${3:-default}"
      dunstctl action "$2" "$ACTION_ID"
      ;;
  esac
''
