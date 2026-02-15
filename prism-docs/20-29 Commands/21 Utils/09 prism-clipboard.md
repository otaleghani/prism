## `prism-clipboard`

A clipboard history manager for Prism. It provides a visual interface to browse, search, and restore previously copied text and images. It leverages [[07 Cliphist]] for storage and [[08 Rofi]] for the selection UI.

## How it works

1. **History Retrieval:** The script invokes `cliphist list` to fetch the stored clipboard history.
2. **User Selection:** This list is piped into `rofi -dmenu`, presenting a searchable menu to the user.
3. **Restoration:**
    - Once an item is selected, it is passed to `cliphist decode` to retrieve the original data (text or image).
    - The decoded data is then piped to `wl-copy`, placing it back into the active Wayland clipboard, ready to be pasted.
    - A system notification confirms the action.
4. **Wipe Functionality:** If run with the `--wipe` flag, it clears the entire clipboard database and sends a notification.

## Dependencies

- `rofi`: The menu interface for selecting history items.
- `cliphist`: The background daemon that tracks clipboard changes.
- `wl-clipboard`: Provides `wl-copy` to interact with the Wayland clipboard.
- `libnotify`: Sends desktop notifications (e.g., "Copied to clipboard").

## Usage 

To open the clipboard history menu:
```bash
prism-clipboard
```

To clear the clipboard history:
```bash
prism-clipboard --wipe
```