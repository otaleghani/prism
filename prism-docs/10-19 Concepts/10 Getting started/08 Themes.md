# Themes

The heart of the system lives at `~/.local/share/prism/current`. This is a **symlink** that points to your active theme directory in `~/.local/share/prism/themes/`.

## How it works

Most Prism-managed applications do not have hardcoded colors. Instead, they point their configuration to the `current/` symlink. When you run `prism-theme`:

1. The symlink at `current/` is updated to point to a new theme folder.
2. A "Refresh Signal" (like `SIGUSR2`) is sent to active applications (Ghostty, Waybar, etc.).
3. Applications re-read the files through the symlink and update their interface instantly.

## Interacting with themes

You have two primary ways to change your system's look:

- **The Visual Picker:** Press `$MOD + CTRL + T` to open a QuickShell menu showing all available themes with color previews.
- **The CLI Tool:** Run `prism-theme <theme-name>` in your terminal for instant switching.

## Theme quirks

Because different applications handle configuration differently, some tools require a small "nudge" to recognize a theme change.

### `fzf` (Terminal Fuzzy Finder)

`fzf` themes are applied via environment variables defined in your shell configuration. Because environment variables are "baked in" when a terminal starts, they won't update in real-time when you switch themes.

- **The Fix:** Open a new terminal tab, or run:
```
source ~/.zshrc
```

### `yazi` (Terminal File Manager)

`Yazi` uses a symlink for its `theme.toml`. While the symlink updates instantly, Yazi only reads its theme configuration when the process starts.

- **The Fix:** Close Yazi (`q`) and reopen it to see the new colors.

### Legacy GTK Applications

Some older GTK2/3 applications may require the window to be closed and reopened to fully redraw their CSS overrides. Prism attempts to refresh the GTK settings via `gsettings`, but a restart is the most reliable method.

## Creating your own theme

To create a custom theme, add a folder to `/etc/prism/overrides/USERNAME/themes/`. A standard Prism theme usually contains different files. Look at one of the pre-installed themes at `~/.local/share/prism/themes/` to see which files you need to create.  Next Prism versions will have utilities to create themes automatically.