{ pkgs, writeShellScriptBin }:
let
  deps = [
    pkgs.jq
    pkgs.coreutils
    pkgs.swaynotificationcenter
    pkgs.gnugrep
  ];
in

writeShellScriptBin "prism-notif-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  swaync-client -s | grep --line-buffered "count" | while read -r line; do
      COUNT=$(echo "$line" | jq '.count')
      DND=$(echo "$line" | jq '.dnd')
      
      if [ "$DND" == "true" ]; then
          CLASS="dnd"
          ICON=""
      elif [ "$COUNT" -gt 0 ]; then
          CLASS="active"
          ICON=""
      else
          CLASS="empty"
          ICON=""
      fi
      
      echo "{\"count\": $COUNT, \"icon\": \"$ICON\", \"class\": \"$CLASS\", \"dnd\": $DND}"
  done
''
