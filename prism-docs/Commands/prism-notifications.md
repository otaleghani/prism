# `prism-notifications`

> [!warning] Deprecated
> This script is considered legacy code. It was previously used to drive the notification widget in the **Waybar** status bar but has been superseded a direct [[QuickShell]] integrations.

The backend controller for the Prism notification center UI. It acts as a bridge between the **Dunst** notification daemon and the visual interface. Its primary role is to fetch and format the notification history into a clean JSON stream and to handle user interactions like dismissing notifications or triggering actions.

## How it works

1. **History Streaming (`listen`):**
    - **Polling:** It polls `dunstctl history` every second to retrieve past notifications.
    - **Formatting:** It uses `jq` to transform the complex raw data from Dunst into a simplified JSON array containing only the necessary fields (`id`, `app`, `summary`, `body`, `urgency`, `actions`).
    - **Ordering:** The list is reversed so that the newest notifications appear at the top of the UI.
    - **Instant Updates:** It sets up a `trap` for the `SIGUSR1` signal. When this signal is received, it forces an immediate refresh of the JSON output, bypassing the 1-second polling delay. This ensures the UI feels responsive when a user dismisses a notification.
2. **Interaction Commands:**
    - **Dismiss:** Closes a specific notification and removes it from the history. It then sends `SIGUSR1` to the running listener to update the UI instantly.
    - **Clear:** Closes all active notifications and wipes the entire history.
    - **Action:** Executes a specific action associated with a notification (e.g., clicking a "Reply" button).

## Dependencies

- `dunst`: The notification daemon and control tool (`dunstctl`).
- `jq`: Essential for parsing and restructuring the notification data.
- `procps`: Provides `pkill` to signal the listener process.
- `coreutils`: Standard utilities.

## Usage

This script is generally run in the background by the UI widget (`listen` mode) and called transiently by UI buttons (`dismiss`, `clear`).

```bash
prism-notifications <command> [args...]
```

## Commands

|**Command**|**Arguments**|**Description**|
|---|---|---|
|`listen`|_None_|Starts the polling loop, outputting JSON history arrays to stdout.|
|`dismiss`|`<id>`|Closes the notification with the given ID and removes it from history.|
|`clear`|_None_|Dismisses all notifications and clears the history.|
|`action`|`<id> [action_id]`|Triggers an action on a notification (defaults to "default").|

## JSON Output Structure (Listen Mode)

```json
[
  {
    "id": 102,
    "app": "Discord",
    "summary": "New Message",
    "body": "Hey, are you there?",
    "urgency": 1,
    "time": 1715623400,
    "actions": [
      { "id": "reply", "label": "Reply" }
    ]
  }
]
```