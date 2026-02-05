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
      # POLLING MODE
      # Since subscribe is unavailable/unreliable, we poll history every second.
      # This ensures the widget stays in sync with Dunst.
      while true; do
         HISTORY=$(dunstctl history 2>/dev/null)
         
         if [ -n "$HISTORY" ]; then
             echo "$HISTORY" | jq -c '[.data[][].id.data as $id | .data[][] | {
               id: $id, 
               app: .appname.data, 
               summary: .summary.data, 
               body: .body.data,
               urgency: .urgency.data,
               time: .timestamp.data,
               actions: (if .actions.data then [.actions.data | range(0; length; 2) as $i | {id: .[$i], label: .[$i+1]}] else [] end)
             }]'
         else
             echo "[]"
         fi
         sleep 1
      done
      ;;
      
    "dismiss")
      dunstctl close "$2"
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
