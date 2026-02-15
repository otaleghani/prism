# `prism-install-webapp`

An interactive TUI wizard that turns any website into a standalone, "single-instance" desktop application. It automates the creation of Linux desktop entries (`.desktop` files), fetches high-quality icons, and ensures the app integrates with Prism's window-focusing logic.

## How it works

1. **Data Acquisition:** Uses `gum` to prompt for the app name, URL, and a remote icon link (PNG recommended).
2. **Icon Management:** Downloads the provided icon via `curl` and stores it in a dedicated local directory (`~/.local/share/applications/icons`) for system-wide access.
3. **Desktop Entry Generation:** Creates a file in `~/.local/share/applications/` with the following key attributes:
    - **`Exec`:** Points to `prism-focus-webapp`. This ensures that if the app is already open, clicking the icon focuses the existing window instead of launching a new one.
    - **`Icon`:** Points to the newly downloaded local image.
    - **`Categories`:** Categorized as "Network" and "WebBrowser" so it shows up in the correct sections of your app launcher.
4. **Registration:** Once the file is created and made executable, your application launcher (Rofi/Wofi) will pick it up immediately.

## Usage

```bash
prism-install-webapp
```