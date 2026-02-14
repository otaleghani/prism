# `prism-brightness`

A script to monitor and control the screen brightness of the system. It is designed to drive brightness sliders and indicators in the Prism UI (e.g., QuickShell or Eww) and handle keyboard shortcuts for brightness adjustment.

## How it works

1. **Status Retrieval (`get_status`):**
    - It queries `brightnessctl` specifically looking for devices with the class `backlight`.
    - **Desktop Fallback:** If no backlight device is found (common on desktops with external monitors), it defaults to reporting 100% brightness to prevent UI errors.
    - **Icon Logic:**
        - **≥ 70%:** Returns "󰃠" (High).
        - **≥ 30%:** Returns "󰃟" (Medium).
        - **< 30%:** Returns "󰃞" (Low).
    - Outputs a JSON object containing the percentage and the appropriate icon.
2. **Modes:**
    - **Listen Mode:** Runs an infinite loop that polls the brightness status every 0.5 seconds and prints the JSON to stdout. This is used to update UI widgets in real-time.
    - **Set Mode:** Accepts a value to change the brightness. It intelligently handles raw numbers (from sliders) by appending a `%` sign, ensuring `brightnessctl` interprets "50" as "50%" rather than a raw hardware value. It also supports relative changes (e.g., "5%+").

## Dependencies

- `brightnessctl`: The core tool for controlling backlight devices.
- `coreutils`: Standard utilities.

## Usage

```bash
prism-brightness <command> [value]
```

## Commands

| **Command** | **Arguments** | **Description**                                                                                     |
| ----------- | ------------- | --------------------------------------------------------------------------------------------------- |
| `listen`    | _None_        | Starts a polling loop outputting JSON status every 0.5s.                                            |
| `set`       | `<value>`     | Sets the brightness. Accepts relative (e.g., `5%+`, `5%-`) or absolute (e.g., `50` for 50%) values. |

## JSON Output Format

```json
{"percent": 75, "icon": "󰃠"}
```
