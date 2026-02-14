# `prism-session`

A centralized session management script for Prism OS. It provides a simplified interface for common power and session actions, abstracting away the specific system commands into a unified command set. This script is primarily used as the backend for the Prism logout menu and power button actions.

## How it works

The script uses a simple `case` statement to route the user's intent to the appropriate system daemon:

1. **Locking:** Uses `loginctl` to signal the session manager to lock the screen.
2. **Logging Out:** Employs a two-step process to ensure a clean exit—first killing all processes owned by the current user, then signaling Hyprland to terminate the session.
3. **Power Management:** Delegates `suspend`, `reboot`, and `shutdown` requests directly to `systemctl` (systemd).

## Dependencies

- `systemd`: For `systemctl` and `loginctl`.
- `hyprland`: For the `hyprctl dispatch exit` command.
- `procps`: For `pkill`.

## Usage

```bash
prism-session <action>
```

 ## Supported Actions

|**Action**|**Command Executed**|**Effect**|
|---|---|---|
|`lock`|`loginctl lock-session`|Triggers the screen locker.|
|`logout`|`hyprctl dispatch exit`|Closes the Hyprland session.|
|`suspend`|`systemctl suspend`|Puts the system into a low-power sleep state.|
|`reboot`|`systemctl reboot`|Restarts the computer.|
|`shutdown`|`systemctl poweroff`|Powers down the system completely.|
