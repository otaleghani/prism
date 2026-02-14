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
  TRIGGER_FILE="/tmp/prism_audio_trigger"

  get_state() {
      DEFAULT_SINK=$(pactl get-default-sink)
      
      MASTER_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
      if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"; then
          MASTER_MUTED="true"
      else
          MASTER_MUTED="false"
      fi

      # Sinks
      SINKS=$(pactl -f json list sinks | jq -c --arg def "$DEFAULT_SINK" '[.[] | {
          id: .index, 
          name: .name,
          desc: .description, 
          vol: (.volume."front-left".value_percent | sub("%";"") | tonumber), 
          is_default: (.name == $def)
      }]')

      # Apps
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

      echo "{\"master\": {\"vol\": $MASTER_VOL, \"muted\": $MASTER_MUTED}, \"sinks\": $SINKS, \"apps\": $APPS}"
  }

  case "$CMD" in
    "listen")
      rm -f "$TRIGGER_FILE"
      (
        pactl subscribe \
        | grep --line-buffered -E "sink|sink-input|server" \
        > "$TRIGGER_FILE"
      ) &
      LISTENER_PID=$!

      # Ensure we kill the listener when this script exits
      trap "kill $LISTENER_PID 2>/dev/null; rm -f $TRIGGER_FILE" EXIT

      # Run the Initial State
      get_state

      # Main Loop (The "Updater")
      # Check for changes every 0.1s. 
      # This effectively limits updates to max 10 per second, saving your CPU/Audio Server.
      while true; do
        if [ -s "$TRIGGER_FILE" ]; then
            # File has content -> Events happened!
            
            # Clear the file immediately
            : > "$TRIGGER_FILE"
            
            # Run the update
            get_state
        fi
        # Wait a tiny bit before checking again
        sleep 0.1
      done
      ;;
      
    "set-volume")
      pactl set-sink-input-volume "$2" "$3%"
      ;;

    "set-master")
      pactl set-sink-volume @DEFAULT_SINK@ "$2%"
      ;;

    "toggle-mute")
       pactl set-sink-mute @DEFAULT_SINK@ toggle
       ;;
      
    "set-default")
      pactl set-default-sink "$2"
      pactl list short sink-inputs | cut -f1 | while read -r id; do
          pactl move-sink-input "$id" "$2"
      done
      ;;
  esac
''
