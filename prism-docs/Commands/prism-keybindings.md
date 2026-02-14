# `prism-keybindings`

A helper utility that parses your [[Hyprland]] configuration files to generate a searchable list of all active keybindings. It presents these bindings in a clean, readable format using [[Rofi]], making it easy to memorize shortcuts or find specific commands without digging through configuration files manually.

## How it works

1. **Scanning:** The script recursively scans the `$HOME/.config/hypr` directory for lines starting with `bind =`.
2. **Parsing & Formatting:** It uses `sed` to transform the raw Hyprland config syntax into human-readable text:
    - Replaces `$mainMod` with `SUPER`.
    - Formats the action arrow (e.g., `-> Exec:`).
    - Joins modifier keys with `+`.
3. **Display:** The processed list is piped into `rofi -dmenu`, creating a searchable window where users can type keywords (like "browser" or "volume") to see the associated hotkeys.

**Dependencies**

- `rofi`: Displays the keybinding list.
- `gnugrep`: Searches the config files.
- `gnused` & `gawk`: Text processing tools for formatting the output.

## Usage 

This script is bound to a key so help is always accessible.

```bash
prism-keybinds
```