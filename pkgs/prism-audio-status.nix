{ pkgs, writeShellScriptBin }:
let
  deps = [
    pkgs.coreutils
    pkgs.pulseaudio # for pactl
    pkgs.gnugrep
  ];
in

writeShellScriptBin "prism-audio-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  get_vol() {
      VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)
      MUTE=$(pactl get-sink-mute @DEFAULT_SINK@)
      if [[ "$MUTE" == *"yes"* ]]; then
          echo "{\"icon\": \"󰝟\", \"percent\": $VOL, \"class\": \"muted\"}"
      else
          if [ "$VOL" -ge 50 ]; then ICON="";
          elif [ "$VOL" -ge 25 ]; then ICON="";
          else ICON=""; fi
          echo "{\"icon\": \"$ICON\", \"percent\": $VOL, \"class\": \"\"}"
      fi
  }

  get_vol
  pactl subscribe | grep --line-buffered "sink" | while read -r _; do
      get_vol
  done
''
