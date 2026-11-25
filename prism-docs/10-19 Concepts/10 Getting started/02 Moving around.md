# Moving around

Prism is designed for speed, using a "Home Row" philosophy where your most frequent actions never require you to move your hands far from the typing position.

## Window management

Prism uses a dynamic tiling engine. By default, windows don't overlap; they "tile" to fill the screen.

- **Focusing:** Use `$SUPER` + `H/J/K/L` (Vim keys) to move your focus between windows.
- **Moving:** Use `$SUPER` + `SHIFT` + `H/J/K/L` to physically move the active window's position in the layout.
- **Resizing:** If a layout isn't perfect, hold `$SUPER` + `CTRL` + `SHIFT` and use `H/J/K/L` to grow or shrink the active window.
- **Floating:** Sometimes you need a window to hover (like a calculator). Press `$SUPER` + `Y` to toggle a window between **Tiling** and **Floating** modes.

## Groups and tabs

Prism allows you to "Group" windows together, effectively creating tabs within a single window area.

- **Creating a Group:** Press `$SUPER` + `R` on a window to turn it into a group.
- **Adding to Group:** Hold `$SUPER` + `CTRL` and use `H/J/K/L` to "push" a window into an adjacent group.
- **Navigation:** Use `$SUPER` + `W` (Back) and `$SUPER` + `E` (Forward) to cycle through the windows inside a group.
- **Removing:** Press `$SUPER` + `SHIFT` + `R` to pull the current window out of a group.

## The scratchpad

Think of the **Special Workspace** as a hidden drawer. It’s perfect for windows that you want to summon and hide instantly.

- **Toggle Drawer:** Press `$SUPER` + `T` to show or hide the special workspace.
- **Stash Window:** Press `$SUPER` + `SHIFT` + `T` to move the currently active window into that hidden drawer.

### Presenting with private notes

The scratchpad is visible in a capture of the monitor whenever it is open. Hyprland's [`no_screen_share` rule](https://wiki.hypr.land/configuring/core/rules/window-rules/) replaces protected windows with black rectangles; it does not reveal the desktop underneath them.

Use the **presentation desktop** to share an entire desktop while keeping notes private:

1. Press `$SUPER + SHIFT + O` (or run `prism-present`) to open Hyprland inside a window. Maximize that window with the outer desktop's `$SUPER + CTRL + F` if needed.
2. Focus the inner desktop and press `$SUPER + ALT + S` to open its Chromium browser. This uses a separate, persistent profile; sign into Meet or Teams there.
3. Start sharing **Entire Screen** from that browser and select the inner `WAYLAND-1` output. Launch the apps you will present from the inner terminal (`$SUPER + ALT + A`). Existing outer windows cannot be moved into the inner compositor.
4. Keep notes on the outer desktop's scratchpad. `$SUPER + T` opens it; `$SUPER + SHIFT + M` toggles microphone mute. Outer notes and overlays are outside the inner capture, so they leave no black rectangles.

Inside the presentation desktop, add `ALT` to the usual shortcuts: `$SUPER + ALT + [1-9]` switches workspaces, `$SUPER + ALT + [H J K L]` changes focus, and `$SUPER + ALT + CTRL + M` closes the presentation desktop and its apps.

The launcher gives the inner desktop its own screen-sharing portal while retaining access to the system's audio server. Share from the inner browser: sharing the physical monitor from an outer browser includes your notes. Everything you open **inside** the presentation desktop is visible in its screen capture.

## The interactive panels

Prism uses [[Quickshell]] and [[Rofi]] to provide interactive overlays and menus. 

- **The Sidebar:** `$SUPER` + `CTRL` + `B` opens the main system sidebar for quick toggles.
- **Dashboard/Apps:** `$SUPER` + `0` opens the Prism App Launcher.
- **Notifications:** `$SUPER` + `N` opens the notification center.
- **Audio Mixer:** `$SUPER` + `M` opens the TUI audio mixer.
- **Calendar:** `$SUPER` + `SHIFT` + `C` toggles the system calendar.

## Workspaces

Prism handles workspaces numerically (`1-9`), but it also features specialized workspaces for specific tasks:

- **AI/Tools:** `$SUPER` + `D` (Workspace 97)
- **Chat/Comm:** `$SUPER` + `SHIFT` + `G` (Workspace 98)
- **Music:** `$SUPER` + `G` (Workspace 99)

## Useful reference 

|**Action**|**Keybinding**|
|---|---|
|**Open Terminal**|`$SUPER + A`|
|**Open Browser**|`$SUPER + S`|
|**Kill Window**|`$SUPER + CTRL + Q`|
|**System Settings**|`$SUPER + Z`|
|**Screenshot (Region)**|`$SUPER + SHIFT + P`|
|**Screen Record (Start)**|`$SUPER + O`|
|**Screen Record (Stop)**|`$SUPER + CTRL + O`|
