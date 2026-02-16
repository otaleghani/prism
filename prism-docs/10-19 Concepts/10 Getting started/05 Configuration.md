# Configuration

The primary user configuration resides in `~/.config/prism`.

In its purest form, this directory contains only two files:

1. **`flake.nix`**: Your system's DNA (Drivers, Users, System Packages).
2. **`flake.lock`**: The version manifest that ensures reproducibility.

Everything else—your themes, your keybinds, and your app configs—is managed by the override system.

## Overrides

Prism ships with defaults for applications like [[Hyprland]], [[QuickShell]], and [[Neovim]]. On every system update or activation, Prism **re-writes** these defaults to ensure your system doesn't "drift" into a broken state.

To prevent your custom settings from being wiped, you must place them in the `overrides/` directory.

## Managing dotfiles with `prism-save`

The `prism-save` utility is your bridge between "live" configuration and "persistent" overrides. It works similarly to `git` by tracking specific files.

### Tracking a file

If you have modified a config (e.g., `~/.config/nvim/init.lua`) and want to keep those changes permanently:

```bash
prism-save ~/.config/nvim/init.lua
```

**What happens?**

1. The file path is added to `~/.prismsave` (your tracking list).
2. The file is copied to `/etc/prism/overrides/$USER/.config/nvim/init.lua`.
3. On the next update, Prism will see this file in your overrides and apply it **after** the defaults.

### Syncing all changes

If you've edited multiple tracked files and want to "commit" their current state to your overrides:

```bash
prism-save
```

### Removing a track

To stop overriding a file and return to Prism's defaults:

```bash
prism-save delete ~/.config/nvim/init.lua
```

## Themes and wallpapers

Themes and wallpapers follow a specific directory structure within your user overrides. Prism looks for these folders to populate your Rofi pickers (`$SUPER + CTRL + T` and `$SUPER + CTRL + W`).

| **Asset Type**        | **Override Path**                           |
| --------------------- | ------------------------------------------- |
| **Custom Themes**     | `/etc/prism/overrides/USERNAME/themes/`     |
| **Custom Wallpapers** | `/etc/prism/overrides/USERNAME/wallpapers/` |

### Creating a Custom Theme

1. Create a folder in the path above (e.g., `my-cool-theme`).
2. Add your `colors.json` or `waybar.css`.
3. Prism will automatically detect this folder and add it to your theme list.

## Why use this system?

- **Atomic Rollbacks:** If you mess up an override, you can delete it and instantly return to a working Prism default.
- **Version Control:** Your entire `overrides/` folder can be committed to a Git repository, making it easy to sync your personal "flavor" across multiple machines.
- **Cleanliness:** Your `$HOME` directory stays clean, as the "source of truth" lives safely within your Prism Flake.