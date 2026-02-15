# `prism-monitor`

A configuration utility for managing monitor settings in [[01 Hyprland]] (resolution, positioning, scaling). It simplifies the process by opening the monitor configuration file in your default text editor and automatically applying the changes once you close the editor. It also offers an optional step to persist these changes to your Prism OS configuration overrides.

## How it works

1. **Terminal Wrapper:**
    - The script checks if it is running inside a terminal.
    - If launched from a GUI launcher (like Rofi) or a keybind, it automatically re-launches itself inside a new terminal window using `prism-tui`. This ensures you have a visible interface to edit the text file.
2. **Editing:**
    - It opens `$HOME/.config/hypr/monitors.conf` using your system's default editor ([[02 Neovim]]).
    - If the file doesn't exist, it creates a default one.
    - **The script pauses here** while you edit the file.
3. **Automatic Reload:**
    - As soon as you save and close the text editor, the script resumes.
    - It immediately executes `hyprctl reload`, forcing Hyprland to apply the new monitor settings without requiring a logout.
    - A notification confirms the reload.
4. **Persistence (Optional):**
    - If the `prism-save` utility is available on the system, the script triggers a Rofi menu asking: _"Save to Prism Overrides?"_
    - If you select "Yes", it calls `prism-save` to commit the changes to your permanent Nix configuration (e.g., Flake overrides).

## Dependencies

- `prism-tui`: Required to launch the terminal window if not already present.
- `hyprland`: Provides `hyprctl` to reload the configuration.
- `rofi`: Used for the "Save" confirmation menu.
- `libnotify`: Sends desktop notifications.
- `prism-save` (Optional): A helper script for managing persistent configuration storage.

## Usage 

Trigger via the application launcher or run in a terminal:

```bash
prism-monitor
```

## Configuration file 

The settings are stored in: `~/.config/hypr/monitors.conf`

**Example Monitor Config**

```
# monitor=NAME,RESOLUTION,POSITION,SCALE
monitor=DP-1, 2560x1440@144, 0x0, 1
monitor=HDMI-A-1, 1920x1080@60, 2560x0, 1
```