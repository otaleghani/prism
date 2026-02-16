# Webapps

Most of the work these days is done on the browser. For this reason Prism allows you to install websites as apps by strip away the browser UI (address bars, bookmarks, and tabs) to let the site feel like a native part of your operating system.

## Installing a webapp

To turn a website into a Prism app, use the **`prism-install-webapp`** utility.

1. Launch the tool from your terminal or the **Prism Settings** menu.
2. Provide the **URL** (e.g., `https://web.whatsapp.com`).
3. Provide a **Name** (e.g., `WhatsApp`).
4. Provide an icon URL for the service.
 
 This will Create a custom `.desktop` entry in `~/.local/share/applications`, allowing you to search this webapp like any other app installed in your system.

## Uninstalling a webapp

Managing your webapp library is handled through the **`prism-uninstall-webapp`** TUI. This program will simply delete the entry for the application.