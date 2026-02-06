{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.brightnessctl
    pkgs.jq
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-brightness" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  CMD="$1"

  get_status() {
    # brightnessctl -m output: name,class,current,max,percent%
    # We filter for class 'backlight' to ignore leds/kbd
    DATA=$(brightnessctl -m -c backlight | head -n 1)
    
    if [ -z "$DATA" ]; then
        # Fallback for desktops (always 100%)
        echo '{"percent": 100, "icon": "󰃠"}'
        return
    fi
    
    PERC=$(echo "$DATA" | cut -d',' -f4 | tr -d '%')
    
    if [ "$PERC" -ge 70 ]; then ICON="󰃠";
    elif [ "$PERC" -ge 30 ]; then ICON="󰃟";
    else ICON="󰃞"; fi
    
    echo "{\"percent\": $PERC, \"icon\": \"$ICON\"}"
  }

  case "$CMD" in
    "listen")
      # Polling loop
      while true; do
        get_status
        sleep 0.5
      done
      ;;
      
    "set")
      # $2 can be "5%+", "5%-", or just "50" (from slider)
      VAL="$2"
      # If raw number from slider, append %
      if [[ "$VAL" =~ ^[0-9]+$ ]]; then VAL="$VAL%"; fi
      brightnessctl set "$VAL" -q
      ;;
  esac
''
