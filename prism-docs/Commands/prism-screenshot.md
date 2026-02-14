# `prism-screenshot`

`prism-screenshot` is the comprehensive image capture utility for Prism. It goes beyond simple screen grabbing by offering "Smart Logic" that understands the layout of your windows and monitors. It features screen freezing (via `wayfreeze`) for pixel-perfect selection and integration with `satty` for immediate annotation, highlighting, or blurring.

## How it works

1. **Geometry Intelligence:** The script queries `hyprctl` to map out the exact coordinates and dimensions of every open window and monitor on the active workspace.
2. **Screen Freezing:** When a capture is initiated, it uses `wayfreeze` to lock the screen content. This prevents animations or moving windows from shifting while you are trying to select a specific area.
3. **Selection Modes:**
    - **Smart Mode (Default):** A hybrid behavior. If you click and drag, it acts like a normal region selector. If you simply _click_ once, the script uses a collision detection algorithm to find which window was under your cursor and automatically snaps the screenshot to that window's borders.
    - **Windows Mode:** Uses `slurp` but forces the selection to snap to the geometry of existing windows.
    - **Region/Fullscreen:** Standard manual area or entire monitor capture.
4. **Processing & Annotation:** * By default, the raw capture is piped into **Satty**, a modern annotation tool. Here, you can draw arrows, add text, or redact sensitive information before saving.
    - It can also be run in "Copy" mode for immediate clipboard storage without an intermediate UI.

## Dependencies

- `grim` & `slurp`: The core Wayland capture and selection tools.
- `wayfreeze`: Freezes the compositor output during selection.
- `satty`: The annotation and editing interface.
- `hyprland`: Provides window and monitor metadata via `hyprctl`.
- `wl-clipboard`: Handles the handoff to the system clipboard.

## Usage

```bash
prism-screenshot [mode] [processing]
```

## Arguments

|**Argument**|**Options**|**Description**|
|---|---|---|
|**mode**|`smart`, `region`, `windows`, `fullscreen`|Defines how the area is selected.|
|**processing**|`edit`, `copy`|`edit` opens Satty; `copy` skips editing and goes to clipboard.|

## Example Commands

- **Quick Annotation (Smart):** `prism-screenshot`
- **Direct to Clipboard:** `prism-screenshot region copy`
- **Capture Whole Monitor:** `prism-screenshot fullscreen edit`

## The Smart Capture logic

The script calculates the area of your selection. If the area is smaller than 20 pixels (indicating a click rather than a drag), the script performs a collision check:

1. It iterates through the list of window rectangles provided by Hyprland.
2. It checks if the click coordinates $(X, Y)$ fall within the bounds of a window.
3. It sets the capture coordinates to match that window exactly.