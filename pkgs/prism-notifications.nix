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
  LAST_ID_FILE="/tmp/prism-last-notif"

  # Helper to format Dunst History JSON for Eww
  # Extracts: id, app, summary, body, urgency, time, actions
  get_history() {
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

  case "$CMD" in
    "listen")
      # 1. Output initial history on start
      get_history

      # 2. Listen to Dunst events stream
      # We use jq to parse the event type and data in one go
      dunstctl subscribe | jq --unbuffered -c '.' | while read -r event; do
        
        TYPE=$(echo "$event" | jq -r '.[0]')
        
        if [ "$TYPE" == "notification" ]; then
            # --- NEW NOTIFICATION RECEIVED ---
            DATA=$(echo "$event" | jq '.[1]')
            NEW_ID=$(echo "$DATA" | jq -r '.id')
            
            # A. Prevent Pile-up: Close the previous notification
            if [ -f "$LAST_ID_FILE" ]; then
                OLD_ID=$(cat "$LAST_ID_FILE")
                if [ "$OLD_ID" != "$NEW_ID" ] && [ -n "$OLD_ID" ]; then
                    # Closing it moves it to history
                    dunstctl close "$OLD_ID" >/dev/null 2>&1
                fi
            fi
            echo "$NEW_ID" > "$LAST_ID_FILE"

            # B. Construct "Live" JSON for Eww
            # We take the new notification data and prepend it to the history
            # This makes it appear in the widget INSTANTLY, even while on screen.
            
            # Format the single active notification to match history schema
            ACTIVE_ITEM=$(echo "$DATA" | jq '{
               id: .id,
               app: .appname,
               summary: .summary,
               body: .body,
               urgency: .urgency,
               time: .timestamp,
               actions: (if .actions then [.actions | range(0; length; 2) as $i | {id: .[$i], label: .[$i+1]}] else [] end)
            }')
            
            # Fetch history (which contains everything EXCEPT the active one usually)
            HISTORY=$(get_history)
            
            # Merge: [Active] + [History]
            echo "$HISTORY" | jq --argjson new "$ACTIVE_ITEM" '[$new] + .'

        elif [ "$TYPE" == "removed" ]; then
            # --- NOTIFICATION CLOSED ---
            # It is now in history (or gone). Refresh from history source.
            get_history
        fi
      done
      ;;
      
    "dismiss")
      # Close active popup
      dunstctl close "$2"
      # Also remove from history
      dunstctl history-rm "$2"
      ;;
      
    "clear")
      dunstctl close-all
      dunstctl history-clear
      ;;
      
    "action")
      ACTION_ID="''${3:-default}"
      dunstctl action "$2" "$ACTION_ID"
      ;;
  esac
''
