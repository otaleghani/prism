{ pkgs, writeShellScriptBin }:
let
  deps = [
    pkgs.coreutils
    pkgs.networkmanager
    pkgs.gnugrep
  ];
in

writeShellScriptBin "prism-net-status" ''
      export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Check connectivity
  TYPE=$(nmcli -t -f TYPE,STATE dev | grep ":connected" | head -n 1 | cut -d: -f1)

  if [ "$TYPE" == "wifi" ]; then
      SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep "^yes" | cut -d: -f2)
      echo "{\"icon\": \"\", \"text\": \"$SSID\", \"class\": \"wifi\"}"
  elif [ "$TYPE" == "ethernet" ]; then
      echo "{\"icon\": \"󰈀\", \"text\": \"Ethernet\", \"class\": \"eth\"}"
  else
      echo "{\"icon\": \"󰤮\", \"text\": \"Disconnected\", \"class\": \"disconnected\"}"
  fi
''
