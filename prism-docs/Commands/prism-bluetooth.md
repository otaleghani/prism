# `prism-bluetooth`

A convenience wrapper that launches the system's Bluetooth management interface. It uses [[bluetui]], a terminal-based user interface (TUI), to manage Bluetooth devices, connections, and scanning.

## How it works

1. **Environment Setup:** Ensures `bluetui` is in the system `PATH`.
2. **Execution:** Passes the `bluetui` command to `prism-tui`. This suggests that `prism-tui` is a helper script responsible for spawning a new terminal window (likely floating or centered) to host the TUI application.

## Dependencies

- `bluetui`: A TUI for managing Bluetooth on Linux.
- `prism-tui`: A wrapper script (internal to Prism) used to launch terminal applications in a specific window configuration.

## Usage

Trigger via the application launcher or bind to a key (e.g., in the settings menu).

```bash
prism-bluetooth
```
