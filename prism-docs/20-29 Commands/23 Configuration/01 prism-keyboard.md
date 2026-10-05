# `prism-keyboard`

A utility for changing the system keyboard layout on the fly. It provides a comprehensive, searchable list of all available X11 keyboard layouts (e.g., US, German, Dvorak) via [[08 Rofi]]. When a selection is made, the change is applied instantly to the current session and saved permanently to the [[01 Hyprland]] configuration.

## How it works

1. **Discovery:** The script locates the `base.lst` rules file provided by the `xorg.xkeyboardconfig` package. This file serves as the master list of valid keyboard layouts on Linux.
2. **Parsing:** It uses `awk` to extract layout codes (like `us`, `de`, `fr`) and their full descriptions (like "English (US)", "German") from the rules file. If the file is missing (rare), it falls back to a short list of common layouts.
3. **Selection:** The list is piped into `rofi`, allowing the user to search by country name or language (e.g., typing "Italy" finds the `it` code).
4. **Application:**
    - **Immediate:** Uses `hyprctl eval 'hl.config({ input = { kb_layout = "it" } })'` (with the selected layout) to switch without restarting the session.
    - **Saved:** Updates the quoted `kb_layout` field in `~/.config/hypr/input.lua`. Use `prism-save` to preserve this change in your overrides when Prism reapplies its defaults.
5. **Feedback:** Sends a desktop notification confirming the new layout.

## Dependencies

- `rofi`: The selection menu interface.
- `hyprland`: Provides `hyprctl` for immediate layout switching.
- `xorg.xkeyboardconfig`: Provides the database of keyboard layouts.
- `gnused`, `gnugrep` & `gawk`: Text processing tools for config updates and parsing.
- `libnotify`: Sends the confirmation notification.

## Usage

To open the keyboard layout selector:

```basy
prism-keyboard
```

> [!note] Configuration
> This script expects `~/.config/hypr/input.lua` (or `$XDG_CONFIG_HOME/hypr/input.lua`) to contain an active `kb_layout = "us",` field inside the input table. It reports an error if the file or field is missing.
