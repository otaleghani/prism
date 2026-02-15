# `prism-ctl`

`prism-ctl` is the central command-line interface for interacting with the [[Quickshell]] frontend. It functions as an orchestrator that translates simple terminal commands into visual actions. By utilizing a "Signal-via-Touch" architecture, it allows scripts, keybindings, and hardware buttons to trigger complex UI state changes without requiring the scripts to have direct knowledge of the Quickshell API.

## How it works

The script acts as a **Dispatcher**:

1. **Input:** It accepts a high-level intent (e.g., `calendar`).
2. **Signal:** It creates or updates a timestamp on a specific volatile file in `/tmp`.
3. **Reception:** Quickshell (or an intermediary file-watcher) detects this change and updates the visual state (e.g., opening a window, sliding a drawer, or overlaying a power menu).

## Command Reference

| **Action**          | **Trigger Path**                  | **UI Effect**                               |
| ------------------- | --------------------------------- | ------------------------------------------- |
| **`calendar`**      | `/tmp/prism-drawer-calendar`      | Toggles the date and event overview.        |
| **`mixer`**         | `/tmp/prism-drawer-volume`        | Brings up the per-app audio controls.       |
| **`notifications`** | `/tmp/prism-drawer-notifications` | Opens the notification side-panel.          |
| **`wallpapers`**    | `/tmp/prism-drawer-wallpapers`    | Triggers the wallpaper selection drawer.    |
| **`themes`**        | `/tmp/prism-drawer-themes`        | Triggers the theme gallery.                 |
| **`brightness`**    | `/tmp/prism-drawer-brightness`    | Shows the display intensity slider.         |
| **`session`**       | `/tmp/prism-session`              | Launches the system-wide power/logout menu. |
| **`sidebar`**       | `/tmp/prism-sidebar`              | Toggles the sidebar.                        |