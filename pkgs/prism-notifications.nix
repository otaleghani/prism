{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.dunst
    pkgs.jq
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.procps
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-notifications" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CMD="$1"

  case "$CMD" in
    "listen")
      # History processing
      # Converts Dunst history into a structured JSON stream for UI rendering
      update() {
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
      
      # Signal management
      # Enables instant UI refresh via external commands like clear or dismiss
      trap update SIGUSR1
      
      # Initial state
      update || {
        notify-send "Prism System" "Notification listener failed to start." -u critical
        exit 1
      }
      
      # Polling sequence
      # Continuously monitors notification state changes
      while true; do
        sleep 1
        update
      done
      ;;
      
    "dismiss")
      # Targeted removal
      # Closes active popups and purges the specific ID from history
      dunstctl close "$2"
      dunstctl history-rm "$2"
      
      # Signal refresh
      pkill -SIGUSR1 -f "prism-notifications listen"
      ;;
      
    "clear")
      # Bulk cleanup
      # Wipes all active notifications and historical logs
      dunstctl close-all
      dunstctl history-clear
      pkill -SIGUSR1 -f "prism-notifications listen"
      ;;
      
    "action")
      # Interaction handling
      # Triggers specific notification actions based on user selection
      ACTION_ID="''${3:-default}"
      dunstctl action "$2" "$ACTION_ID"
      ;;
  esac
''
