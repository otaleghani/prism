# `prism-theme-list`

`prism-theme-list` is a specialized metadata scraper for the Prism theme engine. Its primary purpose is to provide the **Visual Theme Picker** with a preview of each theme's color palette. Instead of just listing directory names, it "peeks" inside each theme's CSS to extract core hexadecimal color codes.

## How it works

1. **Directory Traversal:** The script scans the `$HOME/.local/share/prism/themes` directory for all subfolders.
2. **Color Extraction:** For each theme found, it attempts to parse `waybar.css`. Using `grep` and `awk`, it looks for specific CSS variables (e.g., `@define-color base`, `@define-color accent`).  
    - **Base:** The primary background color.
    - **Surface:** Secondary backgrounds (cards, headers).
    - **Text:** The primary foreground color.
    - **Accent:** The main highlight/identity color.
    - **Urgent:** The color used for alerts or notifications.
3. **Graceful Fallbacks:** If a theme is missing the `waybar.css` file or specific color definitions, the script provides a set of default "neutral" hex codes to prevent the UI from breaking.
4. **JSON Serialization:** It compiles the collected data into a structured JSON array. This format is easily digestible by modern UI frameworks like **Quickshell** (QML) or **Eww** (Yuck).

## Dependencies

- `jq`: (Used in the environment, though currently, the script manually assembles the JSON string).
- `gnugrep` & `gawk`: Essential for extracting specific values from CSS text files.
- `coreutils`: Standard directory and string manipulation tools.

## Usage

This script is typically called as a "data source" for a dynamic UI component rather than being run manually by a user.

```bash
prism-theme-list
```

## Sample JSON Output


```json
[
  {
    "name": "catppuccin-mocha",
    "colors": {
      "base": "#1e1e2e",
      "surface": "#313244",
      "text": "#cdd6f4",
      "accent": "#cba6f7",
      "urgent": "#f38ba8"
    }
  },
  --SNIP--
]
```