# `prism-wallpaper-list`

`prism-wallpaper-list` is the backend data provider for the Prism visual wallpaper picker. Much like `prism-theme-list`, it doesn't just look for files; it aggregates, deduplicates, and formats metadata from both **Theme-specific** and **User-custom** wallpaper directories into a clean JSON stream.

## How it works

1. **Dual-Path Discovery:** It targets two specific locations:
    - `~/.local/share/prism/current/wall`: The curated wallpapers that come with your active theme.
    - `~/.local/share/prism/wallpapers`: Your personal stash of high-res backgrounds.
2. **Symlink Resolution:** It uses the `-L` flag with `find` to dereference symlinks. This is crucial because Prism uses symlinks for theme management; without this, the script might just see the link rather than the actual image data.
3. **Deduplication:** By piping to `sort -u`, it ensures that if you have the same image in both folders (or a symlink pointing back to a user file), it only appears once in the picker.
4. **JSON Transformation:** It uses `jq` to transform a raw list of file paths into an array of structured objects. Each object contains:
    - `path`: The absolute path for the renderer to load.
    - `name`: A cleaned-up filename (stripped of the path) for the UI label.

## Dependencies

- `jq`: The heavy lifter for JSON construction.
- `findutils`: For robust file searching.
- `coreutils`: For path manipulation and sorting.

## Usage

This is a "plumbing" script, called by Quickshell to populate a grid of image thumbnails.

```bash
prism-wallpaper-list
```

## Sample JSON Output

```json
[
  {
    "path": "/home/user/.local/share/prism/wallpapers/nebula.png",
    "name": "nebula.png"
  },
  {
    "path": "/home/user/.local/share/prism/current/wall/theme-background.jpg",
    "name": "theme-background.jpg"
  }
]
```