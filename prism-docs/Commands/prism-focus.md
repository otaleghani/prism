# `prism-focus`

The core window management utility for the "single-instance" workflow in Prism. This script intelligently switches focus to an existing window if it's already open, or launches the application if it isn't. It serves as the backend logic for [[prism-focus-tui]] and [[prism-focus-webapp]].

## How it works
1. **Input Parsing:**
    - **Argument 1 (`window-pattern`):** The string to search for in open window titles or class names (e.g., "spotify", "firefox").
    - **Argument 2 (`launch-command`):** (Optional) The specific command to run if the window isn't found. If omitted, the script assumes the `window-pattern` is also the command to run.
2. **Window Discovery:**
    - It queries `hyprctl clients -j` to get a JSON list of all open windows in the current Hyprland session.
    - It uses `jq` to filter this list. It searches for a match where either the `class` or the `title` contains the `window-pattern`.
    - **Regex Matching:** It uses regex boundaries (`\b`) to ensure it matches whole words (e.g., searching for "term" won't accidentally match "terminal") and is case-insensitive (`i` flag).
    - It extracts the unique `address` (handle) of the first matching window found.
3. **Action:**
    - **If found:** It executes `hyprctl dispatch focuswindow address:<ADDR>`, instantly bringing that specific window to the foreground and giving it input focus.
    - **If not found:** It executes `hyprctl dispatch exec "<COMMAND>"`, launching the application as a child of the Hyprland process to ensure it inherits the correct environment variables.

## Dependencies

- `jq`: Essential for parsing the JSON output from Hyprland to find window metadata.
- `hyprland`: Provides `hyprctl` for querying window state and dispatching focus/exec commands.

## Usage 

This script is highly versatile and can be used directly in keybindings or other scripts.

```bash
prism-focus <window-pattern> [launch-command]
```

## Examples

**Simple (Pattern = Command):** Checks for a window named "firefox". If missing, runs `firefox`.

```bash
prism-focus firefox
```


**Complex (Pattern != Command):** Checks for a window with "private" in the title. If missing, runs Firefox in private mode.

```bash
prism-focus "private" "firefox --private-window"
```