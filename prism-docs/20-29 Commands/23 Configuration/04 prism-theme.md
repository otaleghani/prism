# `prism-theme`

`prism-theme` is the dynamic heart of Prism's visual customization. Rather than manually editing dozens of config files, this script allows you to swap your entire desktop's look and feel—including window borders, terminal colors, bar styles, and even GTK application colors—in a single command. It uses a **symlink-based architecture**, where various applications point to a "current" theme folder that is updated on the fly.

## How it Works

1. **Symlink Orchestration:**
    The script maintains a master symlink at `~/.local/share/prism/current`. This link points to the directory of your active theme (e.g., `~/.local/share/prism/themes/dracula`).
2. **Interactive Selection:**
    If run without arguments, it opens a **Rofi** menu listing all themes found in your themes directory.
3. **Cross-Application Reloading:**
    Once a theme is selected, the script updates the master symlink and triggers "soft reloads" or signal updates for almost every running component of the OS:
    - **Compositor:** Reloads Hyprland (`hyprctl reload`).
    - **Terminals:** Signals Ghostty (`SIGUSR2`) and Tmux to refresh their color schemes.
    - **UI Elements:** Restarts Waybar and Quickshell, and reloads the Dunst notification daemon.
    - **GTK:** Uses `gsettings` to update system-wide GTK and Icon themes, and injects custom CSS into `~/.config/gtk-4.0/` to ensure Adwaita apps match your colors.
    - **CLI Tools:** Updates Yazi (file manager), Btop (system monitor), and MPV (video player) by linking their local configs to the theme-specific files.
4. **Wallpaper Sync:**
    Automatically calls `prism-wall random` to ensure your background matches the new color palette.

## Usage

|**Command**|**Action**|
|---|---|
|`prism-theme`|Opens the Rofi interactive theme picker.|
|`prism-theme <theme-name>`|Instantly switches to a specific theme by name.|
## Theme folder structure

For a theme to be fully recognized by this script, it should ideally contain:

- `theme.json`: Metadata for GTK and Icon theme names.
- `gtk.css`: Custom CSS overrides for GTK3/4.
- `Theme.qml`: Styling for the Quickshell dashboard.
- `dunst.conf`: Colors for notification popups.
- `yazi.toml` / `btop.theme`: Tool-specific color schemes.
- and others...

## Why a symlink workflow

By using a symlink (`~/.local/share/prism/current`), Prism avoids the "Nix Rebuild" lag. Applications aren't hard-coded to a static Nix store path; they are pointed to a mutable link that the `prism-theme` script controls. This allows for **instant, zero-rebuild theme switching** while still keeping the underlying theme files managed by Nix.