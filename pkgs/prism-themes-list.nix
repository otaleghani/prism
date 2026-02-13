{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.jq
    pkgs.gnugrep
    pkgs.gawk
    pkgs.coreutils
    pkgs.findutils
  ];
in
writeShellScriptBin "prism-theme-list" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  THEMES_DIR="$HOME/.local/share/prism/themes"

  if [ ! -d "$THEMES_DIR" ]; then echo "[]"; exit 0; fi

  # Iterate through themes and build JSON array
  THEMES=()
  for theme_path in "$THEMES_DIR"/*; do
      [ -d "$theme_path" ] || continue
      NAME=$(basename "$theme_path")
      
      CSS="$theme_path/waybar.css"
      
      if [ -f "$CSS" ]; then
          # Extract hex codes using grep/awk
          BASE=$(grep "@define-color base" "$CSS" | awk '{print $3}' | tr -d ';')
          SURFACE=$(grep "@define-color surface0" "$CSS" | awk '{print $3}' | tr -d ';')
          if [ -z "$SURFACE" ]; then SURFACE=$(grep "@define-color surface" "$CSS" | awk '{print $3}' | tr -d ';'); fi
          
          TEXT=$(grep "@define-color text" "$CSS" | awk '{print $3}' | tr -d ';')
          ACCENT=$(grep "@define-color accent" "$CSS" | awk '{print $3}' | tr -d ';')
          URGENT=$(grep "@define-color urgent" "$CSS" | awk '{print $3}' | tr -d ';')
      else
          BASE="#000000"
          SURFACE="#333333"
          TEXT="#ffffff"
          ACCENT="#888888"
          URGENT="#ff0000"
      fi
      
      # Construct JSON Object
      # Note: We use ''${VAR} to escape bash variables from Nix interpolation
      THEMES+=("{\"name\": \"$NAME\", \"colors\": {\"base\": \"''${BASE:-#000}\", \"surface\": \"''${SURFACE:-#222}\", \"text\": \"''${TEXT:-#fff}\", \"accent\": \"''${ACCENT:-#888}\", \"urgent\": \"''${URGENT:-#f00}\"}}")
  done

  # Join array with commas
  # FIX: Escaped THEMES with ''${...} so Nix ignores it and passes it to Bash
  JSON_ARRAY="[$(IFS=,; echo "''${THEMES[*]}")]"

  # Chunk into rows of 3 using jq
  # echo "$JSON_ARRAY" | jq -c '[ . as $list | range(0; length; 3) as $i | $list[$i:$i+3] ]'
  # Just echo the json
  echo "$JSON_ARRAY"
''
