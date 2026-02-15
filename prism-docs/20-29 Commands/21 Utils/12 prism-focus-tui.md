# `prism-focus-tui`

A smart wrapper script designed to enforce a "single-instance" policy for Terminal User Interface (TUI) applications. When you attempt to launch a TUI tool (like [[06 Btop]], [[02 Neovim]], or [[09 Yazi]]) using this script, it checks if an instance is already running.

- **If running:** It immediately focuses the existing window.
- **If not running:** It launches a new instance.

This prevents cluttering the workspace with multiple duplicate terminal windows for the same tool.

## How it works

1. **ID Generation:** It calculates a unique Application ID based on the command's name. For example, if you run `prism-focus-tui btop`, it generates the ID `org.prism.btop`. This convention allows the window manager to track specific TUI windows.
2. **Command Construction:** It builds a safe launch command string, ensuring all arguments (like file paths with spaces) are properly escaped using `printf %q`.
3. **Delegation:** It passes the generated App ID and the constructed launch command to the `prism-focus` utility.
    - `prism-focus` is responsible for querying the window manager (Hyprland) to see if a window with class `org.prism.btop` exists.
    - If found, it focuses it.
    - If not, it executes the launch command (which calls `prism-tui`).

## Dependencies

- `prism-focus`: The core logic script (likely internal) that handles the "check-focus-or-spawn" routine.
- `prism-tui`: The wrapper that actually launches the terminal emulator with the correct App ID.
- `coreutils`: Provides `basename` to extract the program name.

## Usage 

This script is typically used in keybindings or application launchers ([[08 Rofi]]) to ensure consistent behavior for frequently used tools.

```bash
prism-focus-tui <command> [arguments...]
```

## Examples 

To open (or focus) the system monitor:
```bash
prism-focus-tui btop
```

To open (or focus) Neovim:
```bash
prism-focus-tui nvim
```