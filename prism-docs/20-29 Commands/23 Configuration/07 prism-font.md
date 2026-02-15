A localization and aesthetic utility that allows for the instantaneous updating of the system-wide font and font size. It bridges the gap between the static NixOS configuration and the dynamic desktop environment, ensuring that GUI applications (GTK3/4) reflect your preferences without a reboot or rebuild.

## How it works

1. **Font Discovery:** It queries the `fontconfig` database using `fc-list` to find every font family currently installed in the Nix store.
2. **Selection:** * **Family:** You search for the font name using a fuzzy-search **Rofi** menu.
    - **Size:** You input the desired integer (e.g., `12`) into a **Gum** input buffer.
3. **Application:** It utilizes the `gsettings` (D-Bus) interface to push the new font string to the desktop's schema. This affects window titles, menus, and application interfaces immediately.

## Usage

```bash
prism-font
```