# `prism-webapp`

A specialized utility that launches any website as a standalone desktop application. It utilizes Chromium's "App Mode" to strip away the browser's URL bar, tabs, and bookmarks, providing a focused, windowed experience for web services. This script is the foundational tool used by [[prism-ai]], [[prism-chat]], and [[prism-music]].

## How it works

1. **Dependency Check:** It verifies that `chromium` is installed in the system path. Prism relies specifically on Chromium for its `--app` flag consistency.
2. **App Mode Execution:**
    - It uses the `--app="$URL"` flag to launch the site in a minimalist window.
    - It uses `setsid` and `&` to fully detach the Chromium process from the parent terminal. This ensures that even if you close the terminal where the command was typed, the web app stays open.
3. **Output Suppression:** It pipes all browser logs and errors to `/dev/null` to keep the user's terminal clean.

## Dependencies

- `chromium`: The engine used to render the web app.
- `util-linux`: Provides `setsid` for process detachment.


## Usage

```bash
prism-webapp <URL>
```

## Example

To open YouTube in a dedicated, distraction-free window:
```bash
prism-webapp https://www.youtube.com
```