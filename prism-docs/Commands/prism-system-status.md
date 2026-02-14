# `prism-system-status`

`prism-system-status` is an event-driven telemetry script that monitors the state of high-level system services like Wi-Fi, Bluetooth, and Power Management. Unlike `prism-system-monitor`, which focuses on raw hardware usage (CPU/RAM), this script tracks **connectivity** and **system states**, providing a JSON stream used to update UI toggles and dashboard indicators.

## How it works

1. **State Inspection:**
    - **Wi-Fi:** Uses `nmcli` (NetworkManager) to check if any Wi-Fi connection is active and extracts the current SSID.
    - **Bluetooth:** Queries `bluetoothctl` to see if the controller is powered on and if a device is currently connected.
    - **Power Profile:** Fetches the active profile (e.g., `performance`, `balanced`, or `power-saver`) from the `power-profiles-daemon`.
2. **Event-Driven Updates:** Instead of simple constant polling (which wastes CPU), the script utilizes **monitors**:
    - **`nmcli monitor`**: Triggers a refresh the moment a network connection is dropped or established.
    - **`udevadm monitor`**: Listens for hardware-level events, such as a power cable being plugged in or removed.
    - **Heartbeat Fallback:** A 5-second "heartbeat" loop ensures that even if an event isn't captured by the monitors, the UI state remains fresh.
3. **JSON Output:** Every time an event is detected, the script prints a single line of JSON to `stdout`.

## Usage

This script is used as a `script_launcher` or `poll` source for a TUI/GUI status bar.

```bash
prism-system-status
```

## Sample Output

```json
{
  "wifi": { "connected": true, "ssid": "Prism_5G" },
  "bluetooth": { "on": true, "connected": false },
  "profile": "performance"
}
```