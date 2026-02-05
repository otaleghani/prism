{
  pkgs,
  writeShellScriptBin,
  symlinkJoin,
}:

let
  deps = [
    pkgs.socat
    pkgs.jq
    pkgs.gawk
    pkgs.hyprland
    pkgs.coreutils
    pkgs.pulseaudio
    pkgs.networkmanager
    pkgs.dunst
    pkgs.iwd
    pkgs.gnugrep
    pkgs.gnused
    pkgs.procps
  ];

  # 1. Active Window Listener
  activeWindow = writeShellScriptBin "prism-active-window" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    hyprctl activewindow -j | jq --unbuffered -r '.title // "..."'
    socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
      case "$line" in
        activewindow*) hyprctl activewindow -j | jq --unbuffered -r '.title // "..."' ;;
      esac
    done
  '';

  # 2. Audio Listener
  audioStatus = writeShellScriptBin "prism-audio-status" ''
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
    pactl subscribe | grep --line-buffered "sink" | while read -r _; do get_vol; done
  '';

  # 3. Network Status
  netStatus = writeShellScriptBin "prism-net-status" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    ETH_STATUS=$(nmcli -t -f TYPE,STATE dev | grep "ethernet:connected")
    if [ -n "$ETH_STATUS" ]; then
        echo "{\"icon\": \"󰈀\", \"text\": \"Ethernet\", \"class\": \"eth\"}"
        exit 0
    fi
    WIFI_DEV=$(iwctl device list | grep "station" | awk '{print $2}' | head -n 1)
    if [ -z "$WIFI_DEV" ]; then
        echo "{\"icon\": \"󰤮\", \"text\": \"No Device\", \"class\": \"disconnected\"}"
        exit 0
    fi
    SSID=$(iwctl station "$WIFI_DEV" show | grep "Connected network" | sed 's/.*Connected network\s*//')
    if [ -n "$SSID" ]; then
        CLEAN_SSID=$(echo "$SSID" | sed 's/"/\\"/g')
        echo "{\"icon\": \"\", \"text\": \"$CLEAN_SSID\", \"class\": \"wifi\"}"
    else
        echo "{\"icon\": \"󰤮\", \"text\": \"Disconnected\", \"class\": \"disconnected\"}"
    fi
  '';

  # 4. Notification Listener (DUNST FIX)
  notifStatus = writeShellScriptBin "prism-notif-status" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    get_status() {
        if ! dunstctl is-paused >/dev/null 2>&1; then
             echo "{\"count\": 0, \"icon\": \"\", \"class\": \"empty\", \"dnd\": false}"
             return
        fi

        # Dunst Counters
        # displayed: currently shown as popup
        # waiting: queued/unread
        # history: past notifications
        DISPLAYED=$(dunstctl count displayed 2>/dev/null || echo 0)
        WAITING=$(dunstctl count waiting 2>/dev/null || echo 0)
        HISTORY=$(dunstctl count history 2>/dev/null || echo 0)
        PAUSED=$(dunstctl is-paused 2>/dev/null || echo "false")
        
        [[ "$DISPLAYED" =~ ^[0-9]+$ ]] || DISPLAYED=0
        [[ "$WAITING" =~ ^[0-9]+$ ]] || WAITING=0
        [[ "$HISTORY" =~ ^[0-9]+$ ]] || HISTORY=0
        
        TOTAL=$((DISPLAYED + WAITING + HISTORY))
        
        # --- ICON LOGIC ---

        # 1. If Paused (User DND) -> Show Slashed Bell
        if [ "$PAUSED" == "true" ]; then
            CLASS="dnd"
            ICON=""
        # 2. Normal Active
        elif [ "$TOTAL" -gt 0 ]; then
            CLASS="active"
            ICON=""
        # 3. Empty
        else
            CLASS="empty"
            ICON=""
        fi
        
        echo "{\"count\": $TOTAL, \"icon\": \"$ICON\", \"class\": \"$CLASS\", \"dnd\": $PAUSED}"
    }

    get_status
    while true; do
        sleep 2
        get_status
    done
  '';

in
symlinkJoin {
  name = "prism-bar-utils";
  paths = [
    activeWindow
    audioStatus
    netStatus
    notifStatus
  ];
}
