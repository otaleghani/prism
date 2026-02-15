{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.brightnessctl
    pkgs.jq
    pkgs.coreutils
    pkgs.libnotify
  ];
in
writeShellScriptBin "prism-brightness" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CMD="$1"

  # Status generation
  # Queries hardware backlight and formats percentage and icons for UI
  get_status() {
    # Filters for backlight class to avoid interference with keyboard leds
    DATA=$(brightnessctl -m -c backlight | head -n 1)
    
    if [ -z "$DATA" ]; then
        # Fallback for desktops or systems without controllable backlights
        echo '{"percent": 100, "icon": "󰃠"}'
        return
    fi
    
    PERC=$(echo "$DATA" | cut -d',' -f4 | tr -d '%')
    
    # Icon logic based on intensity levels
    if [ "$PERC" -ge 70 ]; then ICON="󰃠";
    elif [ "$PERC" -ge 30 ]; then ICON="󰃟";
    else ICON="󰃞"; fi
    
    echo "{\"percent\": $PERC, \"icon\": \"$ICON\"}"
  }

  case "$CMD" in
    "listen")
      # Data stream
      # Provides continuous updates for the UI dashboard
      while true; do
        get_status
        sleep 0.5
      done
      ;;
      
    "set")
      # Hardware control
      # Accepts relative (5%+) or absolute (50) values
      VAL="$2"
      
      if [[ "$VAL" =~ ^[0-9]+$ ]]; then VAL="$VAL%"; fi

      # Execution with error handling
      brightnessctl set "$VAL" -q || {
        notify-send "Prism Brightness" "Failed to adjust display intensity. Check hardware permissions." -u critical
        exit 1
      }
      ;;

    *)
      # Usage help
      echo "Usage: prism-brightness [listen|set <value>]"
      exit 1
      ;;
  esac
''
