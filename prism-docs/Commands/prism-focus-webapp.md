# `prism-focus-webapp`

A specialized launcher designed to manage web applications with "single-instance" behavior. Instead of opening a new browser tab or window every time you click a shortcut (e.g., for Spotify, ChatGPT, or Discord), this script checks if a window matching the application's title already exists.

- **If found:** It instantly brings that window to the foreground.
- **If not found:** It launches a new instance of the web application at the specified URL.

## How it works

1. **Input Parsing:** It expects two arguments: a **Window Pattern** (a string to identify the app, like "Spotify") and a **Target URL**.
2. **Delegation:** It constructs a launch command using `prism-webapp` (which likely opens the URL in a specific browser mode, e.g., Chrome/Firefox `--app` mode).
3. **Execution:** It passes the pattern and the constructed command to `prism-focus`.
    - `prism-focus` queries the window manager (Hyprland) for a window title matching the pattern.
    - If a match is found, it focuses it.
    - If not, it executes `prism-webapp "<URL>"`.

## Dependencies

- `prism-focus`: The core logic script that handles the "search-focus-or-spawn" routine.
- `prism-webapp`: The wrapper that actually launches the browser in application mode.

## Usage 

This script is the backend for [[prism-ai]], [[prism-chat]], and [[prism-music]].

```bash
prism-focus-webapp <window-pattern> <url>
```

## Examples

To focus or launch ChatGPT:
```bash
prism-focus-webapp "ChatGPT" "https://chatgpt.com"
```

To focus or launch a specific Trello board:
```bash
prism-focus-webapp "Trello" "https://trello.com/b/myboard"
```