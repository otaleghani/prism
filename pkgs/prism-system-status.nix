{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.networkmanager
    pkgs.bluez
    pkgs.power-profiles-daemon
    pkgs.jq
    pkgs.coreutils
    pkgs.gawk
    pkgs.procps
    pkgs.systemd
  ];
in
writeShellScriptBin "prism-system-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Data collection
  # Aggregates network, hardware, and power profile data into a single JSON object
  print_status() {
    # Connectivity status
    # Parses NetworkManager for active SSIDs
    WIFI_STATUS=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | head -n1)
    if [ -n "$WIFI_STATUS" ]; then
        WIFI_CON="true"
        WIFI_SSID=$(echo "$WIFI_STATUS" | cut -d: -f2)
    else
        WIFI_CON="false"
        WIFI_SSID=""
    fi

    # Bluetooth logic
    # Checks controller power and active device connections
    if bluetoothctl show | grep -q "Powered: yes"; then
        BT_ON="true"
        if bluetoothctl info | grep -q "Connected: yes"; then BT_CON="true"; else BT_CON="false"; fi
    else
        BT_ON="false"
        BT_CON="false"
    fi

    # Hardware profile
    # Retrieves the active power-profiles-daemon governor
    PROFILE=$(powerprofilesctl get 2>/dev/null || echo "balanced")

    # Structured output
    # Streams JSON to stdout for panel consumption
    echo "{\"wifi\": {\"connected\": $WIFI_CON, \"ssid\": \"$WIFI_SSID\"}, \"bluetooth\": {\"on\": $BT_ON, \"connected\": $BT_CON}, \"profile\": \"$PROFILE\"}"
  }

  # Initial execution
  print_status

  # Event orchestration
  # Monitors udev and network events to trigger immediate updates
  (
    nmcli monitor &
    udevadm monitor --udev -s power_supply &
    
    # Heartbeat loop
    # Ensures status remains accurate even if an event is missed
    while true; do 
      sleep 10
      echo "heartbeat"
    done
  ) | while read -r event; do
    # Debouncing logic
    # Prevents rapid-fire system events from causing output flicker
    sleep 0.2
    print_status
  done
''
