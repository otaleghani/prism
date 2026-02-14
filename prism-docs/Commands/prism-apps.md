# `prism-apps`

The primary application launcher for Prism. It triggers [[rofi]] in "desktop run" mode, allowing users to quickly search for and launch installed graphical applications based on their `.desktop` entries.

## How it works

1. **Environment Setup:** It temporarily adds the required dependencies to the system `PATH`.
2. **Launch:** It executes `rofi -show drun`, which presents a searchable list of applications.

## Dependencies

- `rofi`: A window switcher, application launcher, and dmenu replacement.

## Usage 

This script is typically bound to a keyboard shortcut (`Super + 0`) within the window manager configuration, but it can also be run manually from a terminal.

```bash
prism-apps
```