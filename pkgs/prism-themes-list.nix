# { pkgs, writeShellScriptBin }:
#
# let
#   deps = [
#     pkgs.jq
#     pkgs.gnugrep
#     pkgs.gawk
#     pkgs.coreutils
#     pkgs.findutils
#   ];
# in
# writeShellScriptBin "prism-theme-list" ''
#   export PATH=${pkgs.lib.makeBinPath deps}:$PATH
#
#   THEMES_DIR="$HOME/.local/share/prism/themes"
#
#   # Validation logic
#   # Ensures an empty JSON array is returned if no theme directory exists
#   if [ ! -d "$THEMES_DIR" ]; then echo "[]"; exit 0; fi
#
#   # Data collection
#   # Iterates through available themes to extract color schemes
#   THEMES=()
#   for theme_path in "$THEMES_DIR"/*; do
#       [ -d "$theme_path" ] || continue
#       NAME=$(basename "$theme_path")
#
#       CSS="$theme_path/waybar.css"
#
#       # Parsing logic
#       # Scans waybar.css for @define-color definitions
#       if [ -f "$CSS" ]; then
#           # Extract hex codes via regex and sanitization
#           BASE=$(grep "@define-color base" "$CSS" | awk '{print $3}' | tr -d ';')
#           SURFACE=$(grep "@define-color surface0" "$CSS" | awk '{print $3}' | tr -d ';')
#           [ -z "$SURFACE" ] && SURFACE=$(grep "@define-color surface" "$CSS" | awk '{print $3}' | tr -d ';')
#
#           TEXT=$(grep "@define-color text" "$CSS" | awk '{print $3}' | tr -d ';')
#           ACCENT=$(grep "@define-color accent" "$CSS" | awk '{print $3}' | tr -d ';')
#           URGENT=$(grep "@define-color urgent" "$CSS" | awk '{print $3}' | tr -d ';')
#       else
#           # Fallback values for themes missing CSS definitions
#           BASE="#000000"
#           SURFACE="#333333"
#           TEXT="#ffffff"
#           ACCENT="#888888"
#           URGENT="#ff0000"
#       fi
#
#       # Object construction
#       # Bundles theme metadata into a single JSON entry
#       THEMES+=("{\"name\": \"$NAME\", \"colors\": {\"base\": \"''${BASE:-#000}\", \"surface\": \"''${SURFACE:-#222}\", \"text\": \"''${TEXT:-#fff}\", \"accent\": \"''${ACCENT:-#888}\", \"urgent\": \"''${URGENT:-#f00}\"}}")
#   done
#
#   # Serialization logic
#   # Joins collected objects into a valid JSON array
#   JSON_ARRAY="[$(IFS=,; echo "''${THEMES[*]}")]"
#
#   # Final output
#   # Streams the array to stdout for UI consumption
#   echo "$JSON_ARRAY"
# ''
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

  # Validation logic
  if [ ! -d "$THEMES_DIR" ]; then echo "[]"; exit 0; fi

  # Data collection
  THEMES=()
  for theme_path in "$THEMES_DIR"/*; do
      [ -d "$theme_path" ] || continue
      NAME=$(basename "$theme_path")
      
      QML="$theme_path/Theme.qml"
      
      # Parsing logic for QML properties
      if [ -f "$QML" ]; then
          # Extracts the hex code between quotes for each color property
          BASE=$(grep "property color base" "$QML" | cut -d '"' -f 2)
          SURFACE=$(grep "property color surface" "$QML" | cut -d '"' -f 2)
          TEXT=$(grep "property color text" "$QML" | cut -d '"' -f 2)
          ACCENT=$(grep "property color accent" "$QML" | cut -d '"' -f 2)
          URGENT=$(grep "property color urgent" "$QML" | cut -d '"' -f 2)
      else
          # Fallback values
          BASE="#000000"
          SURFACE="#333333"
          TEXT="#ffffff"
          ACCENT="#888888"
          URGENT="#ff0000"
      fi
      
      # Object construction (Matching your original style)
      THEMES+=("{\"name\": \"$NAME\", \"colors\": {\"base\": \"''${BASE:-#000}\", \"surface\": \"''${SURFACE:-#222}\", \"text\": \"''${TEXT:-#fff}\", \"accent\": \"''${ACCENT:-#888}\", \"urgent\": \"''${URGENT:-#f00}\"}}")
  done

  # Serialization logic (Matching your original style)
  JSON_ARRAY="[$(IFS=,; echo "''${THEMES[*]}")]"

  # Final output
  echo "$JSON_ARRAY"
''
