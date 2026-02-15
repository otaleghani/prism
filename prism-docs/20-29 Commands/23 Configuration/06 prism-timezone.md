# `prism-timezone`

A straightforward localization utility that allows users to change the system timezone. It provides a searchable, fuzzy-filtered list of all global timezones via [[08 Rofi]]. This is particularly useful for users on the move or those who prefer managing system settings through the keyboard rather than a complex GUI control panel.

## How it works

1. **Data Fetching:** The script uses `timedatectl list-timezones` to retrieve the official IANA timezone database list (e.g., `America/New_York`, `Europe/London`).
2. **Interactive Selection:** This list is piped into **Rofi**, allowing the user to quickly filter by continent or city.
3. **System Update:** Once a selection is made, the script executes `timedatectl set-timezone`.
    - **Note on Permissions:** Since changing the system clock is a privileged action, `timedatectl` will trigger a standard **Polkit** (graphical password) prompt to authorize the change.
4. **Feedback:** Sends a desktop notification confirming the success or failure of the operation.

## Dependencies

- `systemd`: Provides `timedatectl` for querying and setting the time.
- `rofi`: The interactive selection menu.
- `libnotify`: Sends status notifications.