# `prism-keyboard`

A utility for changing the system keyboard layout on the fly. It provides a comprehensive, searchable list of all available X11 keyboard layouts (e.g., US, German, Dvorak) via [[Rofi]]. When a selection is made, the change is applied instantly to the current session and saved permanently to the [[Hyprland]] configuration.

## How it works

1. **Discovery:** The script locates the `base.lst` rules file provided by the `xorg.xkeyboardconfig` package. This file serves as the master list of valid keyboard layouts on Linux.
2. **Parsing:** It uses `awk` to extract layout codes (like `us`, `de`, `fr`) and their full descriptions (like "English (US)", "German") from the rules file. If the file is missing (rare), it falls back to a short list of common layouts.
3. **Selection:** The list is piped into `rofi`, allowing the user to search by country name or language (e.g., typing "Italy" finds the `it` code).
4. **Application:**
    - **Immediate:** Uses `hyprctl keyword input:kb_layout <code`> to switch the layout instantly without restarting the session.
    - **Permanent:** Uses `sed` to update the `kb_layout` line in `$HOME/.config/hypr/input.conf`, ensuring the choice persists after a reboot.
5. **Feedback:** Sends a desktop notification confirming the new layout.

## Dependencies

- `rofi`: The selection menu interface.
- `hyprland`: Provides `hyprctl` for immediate layout switching.
- `xorg.xkeyboardconfig`: Provides the database of keyboard layouts.
- `gnused` & `gawk`: Text processing tools for config updates and parsing.
- `libnotify`: Sends the confirmation notification.

## Usage

To open the keyboard layout selector:

```basy
prism-keyboard
```

> [!note] Configuration
> This script expects your Hyprland input configuration to be located at `$HOME/.config/hypr/input.conf` and to contain a line starting with `kb_layout =`.
> If you changed this line this script will not work.

