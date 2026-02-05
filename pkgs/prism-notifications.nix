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
      
      update
      # Subscribe to events. Note: history-clear might not emit an event in older dunst versions,
      # so the UI might need a manual refresh (close/open) if it doesn't clear instantly.
      dunstctl subscribe | grep --line-buffered "notification" | while read -r _; do
        update
      done
      ;;
      
    "dismiss")
      # Close specific ID (Only works if notification is currently a popup on screen)
      # Dunst does not support deleting individual items from history.
      dunstctl close "$2"
      ;;
      
    "clear")
      # FIX: Close all popups AND clear the history log
      dunstctl close-all
      dunstctl history-clear
      ;;
      
    "action")
      dunstctl action "$2"
      ;;
  esac
''
