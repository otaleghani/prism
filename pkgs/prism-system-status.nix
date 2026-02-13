{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.networkmanager
    pkgs.bluez
    pkgs.power-profiles-daemon
    pkgs.jq
    pkgs.coreutils
    pkgs.gawk
    pkgs.procps # for pkill
    pkgs.systemd # for udevadm
  ];
in
writeShellScriptBin "prism-system-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # 1. Define the status function (Same as before)
  print_status() {
    # WiFi
    WIFI_STATUS=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | head -n1)
    if [ -n "$WIFI_STATUS" ]; then
        WIFI_CON="true"
        WIFI_SSID=$(echo "$WIFI_STATUS" | cut -d: -f2)
    else
        WIFI_CON="false"
        WIFI_SSID=""
    fi

    # Bluetooth (Check simple powered state)
    if bluetoothctl show | grep -q "Powered: yes"; then
        BT_ON="true"
        if bluetoothctl info | grep -q "Connected: yes"; then BT_CON="true"; else BT_CON="false"; fi
    else
        BT_ON="false"
        BT_CON="false"
    fi

    # Power Profile
    PROFILE=$(powerprofilesctl get 2>/dev/null || echo "balanced")

    # Output JSON
    echo "{\"wifi\": {\"connected\": $WIFI_CON, \"ssid\": \"$WIFI_SSID\"}, \"bluetooth\": {\"on\": $BT_ON, \"connected\": $BT_CON}, \"profile\": \"$PROFILE\"}"
  }

  # 2. Initial Print
  print_status

  # 3. The Magic: Monitor Events
  # We combine multiple monitoring streams.
  # 'nmcli monitor' prints lines when network changes.
  # 'udevadm monitor' prints lines when hardware (power/bt) changes.
  # 'powerprofilesctl monitor' isn't easily scriptable, so we rely on dbus-monitor or just poll slighly for that specific part if needed, 
  # but usually udev catches the power plug event.

  (
    nmcli monitor &
    udevadm monitor --udev -s power_supply &
    # We add a fallback 'sleep 5' heartbeat just in case an event is missed
    while true; do sleep 5; echo "heartbeat"; done
  ) | while read -r event; do
    # When ANY line is read from the monitors, we refresh the status.
    # We use a tiny lock/timeout to prevent spamming if 10 events happen at once.
    
    # (Optional: check if enough time passed since last print to avoid CPU spikes)
    print_status
  done
''
