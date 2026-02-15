# `prism-volume`

`prism-volume` is a minimal wrapper for `pamixer`. It provides a standardized interface for controlling system audio, making it easy to map volume keys or build status bar widgets without worrying about the underlying PulseAudio or PipeWire syntax.

## How it works

The script acts as a command router, translating simple arguments into `pamixer` calls. It is designed to be called frequently (e.g., when scrolling over a volume icon or holding down a media key).

1. **Metric Retrieval (`get`):** Returns a space-separated string containing the current volume level and the mute state (e.g., `50 false`). This format is ideal for scripts that need to update a volume slider and a "muted" icon simultaneously.
2. **Incremental Adjustment:**
    - **`up` / `down`:** Changes the volume by exactly **1%** per call. This allows for very fine-grained control compared to the standard 5% steps found on many other systems.
3. **Mute Toggling:** Inverts the current mute state.

## Usage

|**Command**|**Action**|**Keybinding Example**|
|---|---|---|
|`prism-volume up`|Increase volume by 1%|`XF86AudioRaiseVolume`|
|`prism-volume down`|Decrease volume by 1%|`XF86AudioLowerVolume`|
|`prism-volume toggle`|Mute/Unmute audio|`XF86AudioMute`|
|`prism-volume get`|Return `[Volume] [MuteState]`|Status Bar Polling|

## Dependencies

- `pamixer`: The core CLI tool for PulseAudio/PipeWire volume control.