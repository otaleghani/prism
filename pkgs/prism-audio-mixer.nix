{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.pulseaudio
    pkgs.jq
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.procps
  ];
in
writeShellScriptBin "prism-audio-mixer" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CMD="$1"

  # Helper to fetch state
  get_state() {
      DEFAULT_SINK=$(pactl get-default-sink)
      
      # 1. Get Sinks (Outputs)
      # We check if the name matches default to mark it active
      # We parse volume from string "100%" to int 100
      SINKS=$(pactl -f json list sinks | jq -c --arg def "$DEFAULT_SINK" '[.[] | {
          id: .index, 
          name: .name,
          desc: .description, 
          vol: (.volume."front-left".value_percent | sub("%";"") | tonumber), 
          is_default: (.name == $def)
      }]')

      # 2. Get Sink Inputs (Apps)
      # We use a fallback for name (app name -> media name -> "Unknown")
      APPS=$(pactl -f json list sink-inputs | jq -c '[.[] | {
          id: .index, 
          name: (.properties."application.name" // .properties."media.name" // "Unknown"),
          vol: (.volume."front-left".value_percent | sub("%";"") | tonumber),
          icon: (
            if (.properties."application.name" | test("Spotify")) then "" 
            else if (.properties."application.name" | test("Firefox|Chrome|Brave")) then ""
            else "" end
          )
      }]')

      echo "{\"sinks\": $SINKS, \"apps\": $APPS}"
  }

  case "$CMD" in
    "listen")
      get_state
      # Subscribe to changes (new apps, volume changes)
      pactl subscribe | grep --line-buffered -E "sink|sink-input" | while read -r _; do
          get_state
      done
      ;;
      
    "set-volume")
      # $2 = id, $3 = volume
      pactl set-sink-input-volume "$2" "$3%"
      ;;
      
    "set-default")
      # $2 = name
      pactl set-default-sink "$2"
      # Move all current inputs to the new sink
      pactl list short sink-inputs | cut -f1 | while read -r id; do
          pactl move-sink-input "$id" "$2"
      done
      ;;
  esac
''
