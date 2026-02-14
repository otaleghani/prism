# `prism-tui`

A specialized wrapper for launching Terminal User Interface (TUI) applications. Instead of running a TUI command inside your _current_ terminal, this script spawns a **new, detached Ghostty terminal window** specifically dedicated to that application. Crucially, it assigns a predictable Wayland `app_id` (window class) to this new window, enabling precise window management rules in Hyprland (e.g., forcing floating mode or specific sizing).

## How it works

1. **ID Generation:** It takes the command name (e.g., `btop`) and constructs a unique Application ID: `org.prism.btop`.
2. **Terminal Check:** It verifies that `ghostty` (the default terminal for Prism) is installed. If not, it errors out.
3. **Detached Launch:**
    - It executes `ghostty` with the `--class` flag set to the generated ID.
    - It uses the `-e` flag to pass the command and all its arguments directly to the terminal.
    - It uses `setsid` and `&` to run the process in the background, fully detached from the parent shell. This means closing the terminal you launched it _from_ won't kill the TUI window.

## Dependencies

- `ghostty`: The required terminal emulator.
- `coreutils`: For `basename`.
- `util-linux`: For `setsid`.

## Usage

```bash
prism-tui <command> [arguments...]
```

## Integration with Hyprland 

The primary power of this script lies in the `app_id` it generates. You can use this ID in your `hyprland.conf` to define window rules.

**Example Rule:** To make all `prism-tui` windows float and center:

```
windowrule {
    name = prism_tui
    match:class = ^(org.prism.)(impala|bluetui)$
    stay_focused = on
    
    # Behavior
    float = 1
    center = 1
    dim_around = 0
    
    # Styling
    size = 900 600
    rounding = 15
}

```