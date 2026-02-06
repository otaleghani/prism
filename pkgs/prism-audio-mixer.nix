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
      SINKS=$(pactl -f json list sinks | jq -c --arg def "$DEFAULT_SINK" '[.[] | {
          id: .index, 
          name: .name,
          desc: .description, 
          vol: (.volume."front-left".value_percent | sub("%";"") | tonumber), 
          is_default: (.name == $def)
      }]')

      # 2. Get Sink Inputs (Apps)
      # FIX: Use 'elif' for cleaner logic and ' // "" ' to prevent null errors
      APPS=$(pactl -f json list sink-inputs | jq -c '[.[] | {
          id: .index, 
          name: (.properties."application.name" // .properties."media.name" // "Unknown"),
          vol: (.volume."front-left".value_percent | sub("%";"") | tonumber),
          icon: (
            (.properties."application.name" // "") as $name |
            if ($name | test("Spotify"; "i")) then "" 
            elif ($name | test("Firefox|Chrome|Brave"; "i")) then ""
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
