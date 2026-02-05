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
      # Function to dump history as Eww-friendly JSON
      update() {
         # dunstctl history returns complex JSON. We simplify it.
         # We map: id, appname, summary, body, urgency
         dunstctl history | jq -c '[.data[][].id.data as $id | .data[][] | {
           id: $id, 
           app: .appname.data, 
           summary: .summary.data, 
           body: .body.data,
           urgency: .urgency.data,
           time: .timestamp.data
         }]'
      }
      
      # Initial output
      update
      
      # Subscribe to events and update on change
      dunstctl subscribe | grep --line-buffered "notification" | while read -r _; do
        update
      done
      ;;
      
    "dismiss")
      # Close specific ID
      dunstctl close "$2"
      ;;
      
    "clear")
      # Close all
      dunstctl close-all
      ;;
      
    "action")
      # Invoke default action (open app)
      dunstctl action "$2"
      ;;
  esac
''
