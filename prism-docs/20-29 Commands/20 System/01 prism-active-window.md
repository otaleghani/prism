# `prism-active-window`

A utility script designed to monitor and output the title of the currently active window in a [[01 Hyprland]] session. It provides an immediate output upon execution and then continuously updates the output whenever the active window changes.

## How it works

1. **Initial State:** Upon startup, it queries `hyprctl` for the active window's JSON data and uses `jq` to extract the title. If no title is found, it defaults to `...`.
2. **Event Loop:** It connects to the [[01 Hyprland]] event socket (`.socket2.sock`) using `socat`.
3. **Real-time Updates:** It listens for the `activewindow` event. When triggered, it re-queries `hyprctl` to fetch and print the new window title.

## Dependencies

- `socat`: For connecting to the Hyprland UNIX socket.
- `jq`: For parsing JSON output from `hyprctl`.
- `hyprland`: Provides the `hyprctl` command.
- `coreutils`: Standard GNU core utilities.

## Usage

This script is intended to be run as a background process or piped into a status bar module (e.g., Waybar, Eww).

```bash
prism-active-window
```