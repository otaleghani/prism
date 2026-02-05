{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils
    pkgs.networkmanager
    pkgs.iwd # Required for iwctl
    pkgs.gnugrep
    pkgs.gawk
    pkgs.gnused
  ];
in
writeShellScriptBin "prism-net-status" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Check Ethernet (Managed by NetworkManager)
  # We look for any connected ethernet device
  ETH_STATUS=$(nmcli -t -f TYPE,STATE dev | grep "ethernet:connected")

  if [ -n "$ETH_STATUS" ]; then
      echo "{\"icon\": \"󰈀\", \"text\": \"Ethernet\", \"class\": \"eth\"}"
      exit 0
  fi

  # Check Wi-Fi (Managed by IWD)
  # We need to find the station device (usually wlan0)
  # iwctl output parsing can be tricky, so we look for the "Connected network" line.

  # Find the first device in 'station' mode
  WIFI_DEV=$(iwctl device list | grep "station" | awk '{print $2}' | head -n 1)

  if [ -z "$WIFI_DEV" ]; then
      # No wifi device found
      echo "{\"icon\": \"󰤮\", \"text\": \"No Device\", \"class\": \"disconnected\"}"
      exit 0
  fi

  # Get network name if connected
  # Output format: "    Connected network    MyWifiName"
  SSID=$(iwctl station "$WIFI_DEV" show | grep "Connected network" | sed 's/.*Connected network\s*//')

  if [ -n "$SSID" ]; then
      # Escape JSON special chars just in case
      CLEAN_SSID=$(echo "$SSID" | sed 's/"/\\"/g')
      echo "{\"icon\": \"\", \"text\": \"$CLEAN_SSID\", \"class\": \"wifi\"}"
  else
      echo "{\"icon\": \"󰤮\", \"text\": \"Disconnected\", \"class\": \"disconnected\"}"
  fi
''
