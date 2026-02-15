# `prism-settings`

`prism-settings` acts as the central control hub for Prism. Instead of a traditional monolithic settings application, it provides a unified **Rofi-based entry point** that delegates specific configuration tasks to the appropriate specialized Prism utilities. This ensures a consistent, keyboard-driven experience for system management, from hardware configuration (Wi-Fi, Bluetooth, Audio) to aesthetic tweaks (Wallpapers, Themes).

## How it works

1. **Menu Generation:** It compiles a list of human-readable options categorized by system function.
2. **Specialized Delegation:** Once an option is selected, the script uses `exec` to hand off the process to the relevant tool.
    - For TUI-based tools (like `impala` for Wi-Fi or `nvim` for config files), it utilizes `prism-focus-tui` to ensure the application opens in a floating, centered Ghostty terminal window.
    - For GUI-based scripts, it calls them directly.

## Dependencies

- `rofi`: The primary menu interface.
- `prism-focus-tui`: Used to wrap terminal-based settings tools.
- `libnotify`: Used for error handling and status alerts.
- **Internal Scripts:** Relies on the presence of `prism-monitor`, `prism-theme`, `prism-wall`, `prism-keyboard`, and `prism-power`.

## Navigation Map

|**Category**|**Option**|**Command Executed**|**Tool Type**|
|---|---|---|---|
|**System**|Edit Configuration|`nvim /etc/prism`|TUI|
|**Dotfiles**|Edit Dotfiles|`nvim ~/.config`|TUI|
|**Network**|Wi-Fi / Bluetooth|`impala` / `bluetui`|TUI|
|**Hardware**|Monitors|`prism-monitor`|TUI|
|**Hardware**|Audio Mixer|`wiremix`|TUI|
|**Hardware**|Power Profiles|`prism-power`|Script|
|**Appearance**|Theme / Wallpaper|`prism-theme` / `prism-wall`|Script|
|**Localization**|Timezone / Keyboard|`prism-timezone` / `prism-keyboard`|Script|