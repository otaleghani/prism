# `prism-notif-status`

> [!warning] Deprecated
> This script is considered legacy code. It was previously used to drive the notification widget in the **Eww** status bar but has been superseded a direct [[03 QuickShell]] integrations.

A monitoring script for the Dunst notification daemon. It continuously polls the status of the notification server to provide real-time updates on the number of waiting, displayed, and history notifications, as well as the "Do Not Disturb" (paused) state. This output is formatted as JSON for consumption by status bar widgets.

## How it works

1. **Metric Collection:**
    - It queries `dunstctl` to retrieve counts for `displayed` (currently on screen), `waiting` (queued), and `history` (dismissed but stored) notifications.
    - It checks if Dunst is currently paused (`is-paused`), which corresponds to "Do Not Disturb" mode.
2. **Logic & formatting:**
    - **Do Not Disturb (DND):** If Dunst is paused, it sets the icon to a slashed bell () and the class to "dnd".
    - **Active:** If DND is off and there are notifications (total count > 0), it sets the icon to a standard bell () and the class to "active".
    - **Empty:** If DND is off and the count is 0, it sets the class to "empty".
3. **Loop:**
    - The script runs an infinite loop, executing the check and outputting a new JSON line every 2 seconds.

## Dependencies

- `dunst`: The notification daemon provider and control tool (`dunstctl`).
- `jq`: (Included in deps but logic appears to handle JSON manually or via simple echo in this snippet).
- `coreutils`: Standard utilities.

## Usage 

This script is designed to be run as a background process for a UI widget.

```bash
prism-notif-status
```

## JSON Output Examples

**Normal (Empty):**
```json
{"count": 0, "icon": "", "class": "empty", "dnd": false}
```

**Active Notifications:**
```json
{"count": 5, "icon": "", "class": "active", "dnd": false}
```

**Do Not Disturb (Paused):**
```json
{"count": 2, "icon": "", "class": "dnd", "dnd": true}
```