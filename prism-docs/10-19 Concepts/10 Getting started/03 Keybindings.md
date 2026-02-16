# Keybindings

This is the **complete technical reference** for the Prism desktop environment. It is organized by "Keyboard Zones" to help you build muscle memory.

## Modifiers

- `$MOD` = **SUPER** (Windows Key)
- `CONTROL` = **CTRL**
- `SHIFT` = **SHIFT**

## Home Row: Core Applications

The most essential tools are mapped to your left hand on the home row for zero-latency access.

|**Keybinding**|**Action**|**Description**|
|---|---|---|
|`$MOD + A`|**Terminal**|Launches the default system terminal (Ghostty/Kitty)|
|`$MOD + S`|**Browser**|Launches the default web browser|
|`$MOD + D`|**AI Assistant**|Opens the AI interface on **Workspace 97**|
|`$MOD + F`|**File Manager**|Opens the file browser|
|`$MOD + G`|**Music**|Opens the music player on **Workspace 99**|
|`$MOD + SHIFT + G`|**Chat**|Opens communication apps on **Workspace 98**|
|`$MOD + 0`|**App Launcher**|Opens the Prism App Dashboard|


## Navigation and window management

Movement uses the standard **H-J-K-L** (Vim) positions to keep your right hand on the home row.

|**Keybinding**|**Action**|**Description**|
|---|---|---|
|`$MOD + [H J K L]`|**Focus**|Move focus Left, Down, Up, or Right|
|`$MOD + SHIFT + [H J K L]`|**Move**|Move the active window in the tiled layout|
|`$MOD + CTRL + [H J K L]`|**Group**|Push the active window into a group/tab stack|
|`$MOD + CTRL + SHIFT + [H J K L]`|**Resize**|Incrementally resize the active window|
|`$MOD + Y`|**Float**|Toggle between Tiling and Floating modes|
|`$MOD + CTRL + Q`|**Kill**|Close the active window|
|`$MOD + CONTROL + F`|**Fullscreen**|Toggle fullscreen mode (keeping bars visible)|

## Groups and tabs

Groups allow you to stack multiple windows into a single "tabbed" container.

|**Keybinding**|**Action**|**Description**|
|---|---|---|
|`$MOD + R`|**Group Toggle**|Turn the current window into a group container|
|`$MOD + SHIFT + R`|**Ungroup**|Pull the current window out of its group|
|`$MOD + W`|**Prev Tab**|Cycle to the previous window in the group|
|`$MOD + E`|**Next Tab**|Cycle to the next window in the group|

## System and UI controls

The bottom row and specific control keys manage the Prism environment and status panels.

|**Keybinding**|**Action**|**Description**|
|---|---|---|
|`$MOD + Z`|**Settings**|Opens the **Prism Settings** Rofi menu|
|`$MOD + N`|**Notifications**|Opens the SwayNC Notification Center|
|`$MOD + M`|**Audio Mixer**|Opens the WirePlumber/Pulse Audio mixer|
|`$MOD + B`|**Brightness**|Opens the brightness control overlay|
|`$MOD + CTRL + B`|**Sidebar**|Toggles the Quickshell Sidebar|
|`$MOD + SHIFT + C`|**Calendar**|Toggles the system calendar|
|`$MOD + CTRL + W`|**Wallpapers**|Opens the Wallpaper selection menu|
|`$MOD + CTRL + T`|**Themes**|Opens the Theme switcher menu|

## Capture and recording

Prism features high-performance tools for documenting your work.

|**Keybinding**|**Action**|**Description**|
|---|---|---|
|`$MOD + P`|**Screenshot (Full)**|Capture the entire focused monitor|
|`$MOD + SHIFT + P`|**Screenshot (Region)**|Select an area to capture and edit|
|`$MOD + O`|**Record (Start)**|Start 60fps recording with Mic + Desktop Audio|
|`$MOD + CTRL + O`|**Record (Stop)**|Gracefully stop and save the current recording|

## Workspaces and special

|**Keybinding**|**Action**|**Description**|
|---|---|---|
|`$MOD + [1-9]`|**Switch**|Go to workspace 1 through 9|
|`$MOD + SHIFT + [1-9]`|**Move to**|Send the active window to workspace 1 through 9|
|`$MOD + T`|**Scratchpad**|Toggle the hidden Special Workspace|
|`$MOD + SHIFT + T`|**Stash**|Move the active window to the Special Workspace|
## Power and maintenance

| **Keybinding**            | **Action**  | **Description**                                       |
| ------------------------- | ----------- | ----------------------------------------------------- |
| `$MOD + CTRL + P`         | **Session** | Opens the Power/Logout menu                           |
| `$MOD + U`                | **Install** | Opens the Prism Store (Install) in a TUI              |
| `$MOD + SHIFT + CTRL + U` | **Update**  | Rebuilds the system from the local flake              |
| `$MOD + CONTROL + M`      | **Exit**    | Force exit Hyprland (Logs out to TTY/Display Manager) |


> [!NOTE]
> 
> **Profile Shortcuts:** Remember that `$MOD + CTRL + [1-9]` are dynamically assigned based on your current **Prism Persona**. For example, in the `Developer` profile, `$MOD + CTRL + 1` will open the project picker, while in `Gamer`, gives you a list of games that you can launch.