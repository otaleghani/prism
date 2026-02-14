# `prism-wifi`

`prism-wifi` is a specialized convenience wrapper for managing wireless connections. Instead of requiring the user to remember specific terminal commands for NetworkManager, this script launches **Impala**—a modern, efficient TUI for Wi-Fi management—using the standard Prism TUI window rules.

## How it works

The script is a "pass-through" to `prism-tui`:

1. **Environment Setup:** It ensures `impala` is in the execution path.
2. **Window Orchestration:** It calls `prism-tui impala`.
3. **Result:** As defined in the `prism-tui` script, this spawns a new **Ghostty** terminal window with the `app_id` of `org.prism.impala`. This window is automatically caught by Hyprland rules to appear as a floating, centered pop-up rather than a tiled window.

## Dependencies

- `impala`: The underlying TUI application for wireless network selection and configuration.
- `prism-tui`: The Prism utility that handles the detached terminal spawning and class naming.

## Usage

Typically launched via a keybinding (like `Super + W`) or from the `prism-settings` menu.

```bash
prism-wifi
```