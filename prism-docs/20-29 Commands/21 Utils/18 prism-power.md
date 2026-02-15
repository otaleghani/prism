# `prism-power`

A graphical interface for managing the system's power profiles. It allows users to switch between different performance modes (Performance, Balanced, Power Saver) via a [[08 Rofi]] menu. This is particularly useful for laptop users looking to extend battery life or maximize hardware performance on the fly.

## How it works

1. **Daemon Check:** The script verifies that `powerprofilesctl` is available. If the `power-profiles-daemon` service is not active or installed, it sends a critical notification and exits.
2. **State Detection:** It queries the current active power profile to highlight it within the selection menu.
3. **Selection Menu:** It presents three stylized options in Rofi:
    - **Performance ():** Maximizes CPU frequency and hardware responsiveness.
    - **Balanced ():** The default middle-ground for standard usage.
    - **Power Saver ():** Throttles performance to reduce energy consumption and heat.
4. **Application:** Once a profile is selected, the script uses `powerprofilesctl set` to apply the change and sends a confirmation notification with a matching icon.

## Dependencies

- `power-profiles-daemon`: The underlying system service (provides `powerprofilesctl`).
- `rofi`: The menu interface.
- `libnotify`: Sends the confirmation notifications.

## Usage

Run the script via a keyboard shortcut or the application launcher:

```bash
prism-power
```

## Comparison of Power Modes

|**Mode**|**Use Case**|**Typical Behavior**|
|---|---|---|
|**Performance**|Gaming, Compiling, Video Editing|High clock speeds, more fan noise.|
|**Balanced**|Web browsing, Office work|Dynamic scaling based on load.|
|**Power Saver**|Low battery, quiet environments|Low clock speeds, minimal fan usage.|
