{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.pulseaudio
    pkgs.jq
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.procps
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-audio-mixer" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CMD="$1"
  TRIGGER_FILE="/tmp/prism_audio_trigger"

  # State generation
  # Aggregates master volume, sinks, and application streams into JSON
  get_state() {
      DEFAULT_SINK=$(pactl get-default-sink)
      
      MASTER_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
      if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"; then
          MASTER_MUTED="true"
      else
          MASTER_MUTED="false"
      fi

      # Sinks data
      SINKS=$(pactl -f json list sinks | jq -c --arg def "$DEFAULT_SINK" '[.[] | {
          id: .index, 
          name: .name,
          desc: .description, 
          vol: (.volume."front-left".value_percent | sub("%";"") | tonumber), 
          is_default: (.name == $def)
      }]')

      # Application data
      # Maps application names to Nerd Font icons for the UI
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
      # Event subscription
      # Spawns a background process to watch for PulseAudio changes
      rm -f "$TRIGGER_FILE"
      (
        pactl subscribe \
        | grep --line-buffered -E "sink|sink-input|server" \
        > "$TRIGGER_FILE"
      ) &
      LISTENER_PID=$!

      # Cleanup logic
      trap "kill $LISTENER_PID 2>/dev/null; rm -f $TRIGGER_FILE" EXIT

      # Initial state output
      get_state

      # Main update loop
      # Monitors the trigger file and throttles updates to 10Hz
      while true; do
        if [ -s "$TRIGGER_FILE" ]; then
            # Event detected
            : > "$TRIGGER_FILE"
            get_state
        fi
        sleep 0.1
      done
      ;;
      
    "set-volume")
      # Per-app volume adjustment
      pactl set-sink-input-volume "$2" "$3%"
      ;;

    "set-master")
      # System-wide volume adjustment
      pactl set-sink-volume @DEFAULT_SINK@ "$2%"
      ;;

    "toggle-mute")
      # Mute toggle logic
       pactl set-sink-mute @DEFAULT_SINK@ toggle
       ;;
      
    "set-default")
      # Audio output switching
      # Sets default sink and migrates all active streams to it
      pactl set-default-sink "$2"
      pactl list short sink-inputs | cut -f1 | while read -r id; do
          pactl move-sink-input "$id" "$2"
      done
      
      notify-send "Prism Audio" "Output switched to $2" -i audio-speakers
      ;;

    *)
      # Usage help
      echo "Usage: prism-audio-mixer [listen|set-volume|set-master|toggle-mute|set-default]"
      exit 1
      ;;
  esac
''
