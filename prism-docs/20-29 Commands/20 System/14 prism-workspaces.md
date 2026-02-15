# `prism-workspaces`

`prism-workspaces` is a event listener and data provider for workspace management. Its primary goal is to feed real-time workspace states (which ones exist, which one is active, and how many windows each contains) to a UI component like a status bar or dashboard. Unlike a simple polling script, it uses a **Unix socket** to react instantly to compositor events.

## How it works

1. **State Generation (`generate`):**
    - It queries `hyprctl workspaces` to get a list of all current workspaces.
    - It queries `hyprctl monitors` to identify exactly which workspace is currently focused by the user.
    - It uses `jq` to merge this data into a streamlined JSON array. Each object in the array tells the UI:
        - `id`: The workspace number.
        - `active`: A boolean (`true`/`false`) indicating if this is the current view.            
        - `windows`: The count of applications currently living on that workspace.        
2. **The Socket Listener:** Hyprland exposes an event socket (`.socket2.sock`). The script uses `socat` to tap into this stream.
3. **Filtered Reactivity:** Instead of regenerating the JSON for every single mouse movement or internal event, the script uses a `case` statement to filter for specific actions:
    - `workspace`: Switching between workspaces.
    - `createworkspace` / `destroyworkspace`: Dynamic workspace lifecycle changes.
    - `movewindow`: Moving an app from one workspace to another.
4. **Instant Update:** Whenever one of these events occurs, the script immediately runs `generate` again and prints the new JSON to `stdout`.

## Usage

This script is designed to be the "source" for a dynamic UI module that renders workspace icons or numbers.

```bash
prism-workspaces
```

## Sample JSON Output

```bash
[
  {"id": 1, "active": false, "windows": 3},
  {"id": 2, "active": true, "windows": 1},
  {"id": 3, "active": false, "windows": 0}
]
```