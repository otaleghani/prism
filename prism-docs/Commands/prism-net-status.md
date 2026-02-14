# `prism-net-status`

A lightweight network monitoring script designed to feed status bar widgets. It determines the current network connectivity state, prioritizing wired Ethernet connections over Wi-Fi. It outputs the status as a JSON object containing an icon, the connection name (or type), and a CSS class for styling.

## How it works

1. **Ethernet Priority:**
    - The script first queries `NetworkManager` (`nmcli`) to check for any connected Ethernet devices.
    - If an active wired connection is found, it immediately outputs the Ethernet status (Icon: 󰈀) and exits.
2. **Wi-Fi Fallback:**
    - If no Ethernet is detected, it queries the **IWD** daemon (`iwctl`) to find a wireless device in "station" mode.
    - If no wireless device is found, it reports "No Device".
    - If a device exists, it checks for a currently connected network SSID.
    - If connected, it outputs the Wi-Fi icon () and the SSID name.
    - If not connected, it reports "Disconnected".

## Dependencies

- `networkmanager`: Used via `nmcli` to detect wired connections.
- `iwd`: Used via `iwctl` to detect wireless connections and SSIDs.
- `gnugrep`, `gawk`, `gnused`: Text processing tools for parsing command output.

## Usage 

This script is typically run by a status bar widget on a polling interval.

```bash
prism-net-status
```

## JSON Output Examples

**Ethernet Connected:**
```json
{"icon": "󰈀", "text": "Ethernet", "class": "eth"}    
```

**Wi-Fi Connected:**
```json
{"icon": "", "text": "MyHomeNetwork", "class": "wifi"}
```

**Disconnected:**
```json
{"icon": "󰤮", "text": "Disconnected", "class": "disconnected"}
 ```