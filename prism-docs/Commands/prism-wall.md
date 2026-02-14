# `prism-wall`

`prism-wall` is the dedicated wallpaper management utility for Prism. It manages the background image transitions using the `swww` daemon. It intelligently pools wallpapers from two distinct sources: the **Active Theme** (to ensure a curated aesthetic) and a **Custom Wallpapers** folder (for user-added images).

## How it Works

1. **Dual-Source Discovery:**
    The script scans two directories for image files (`.jpg`, `.png`, `.webp`, `.gif`, etc.):
    - **Theme Source:** `~/.local/share/prism/current/wall/` (Linked to the active theme).
    - **User Source:** `~/.local/share/prism/wallpapers/`.
2. **Daemon Management:**
    It checks if the `swww-daemon` is running. If not, it spawns it in the background to ensure transitions are always available.
3. **Transition Engine:**
    When a wallpaper is set, it uses `swww img` with a specific configuration (60 FPS, simple transition type) to create a fade effect rather than a jarring instant change.
4. **Selection Modes:**
    - **Random/Next:** Shuffles the combined list of all found wallpapers and picks one.
    - **Interactive:** Uses `fzf` to allow the user to fuzzy-search through the file paths of available wallpapers.

## Usage

|**Command**|**Action**|
|---|---|
|`prism-wall random`|Picks a random image from the theme or user folders.|
|`prism-wall select`|Opens an interactive fuzzy-search menu in the terminal.|
|`prism-wall set <path>`|Sets a specific image file as the wallpaper.|

## The wallpaper hierarchy

Because `prism-wall` looks inside `~/.local/share/prism/current/wall`, it is tightly coupled with `prism-theme`. When you switch your theme, the "Theme Source" folder changes instantly. Running `prism-wall random` immediately after a theme switch (which is done automatically by the theme script) ensures your desktop background matches your new UI colors.

## Dependencies

- `swww`: The Wayland wallpaper daemon responsible for the rendering and transitions.
- `fzf`: Provides the interactive command-line selection interface.
- `findutils` & `coreutils`: Used for gathering and shuffling the file list.