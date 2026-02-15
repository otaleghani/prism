
# `prism-audio-status`

> [!warning] Deprecated
> This script is considered legacy code. It was previously used to drive the volume widget in the **Eww** status bar but has been superseded by `prism-audio-mixer` and a QuickShell integrations.

A lightweight monitoring script that outputs the current default sink's volume and mute status as a JSON object. It was designed to provide icon-based feedback (high, medium, low, muted) for status bar widgets.

## How it works

1. **Initial State:** Queries `pactl` to determine the current volume percentage and mute status of the default audio sink.
2. **Icon Logic:**
    - **Muted:** Returns "󰝟" with a "muted" class.
    - **> 50%:** Returns "" (High volume).
    - **> 25%:** Returns "" (Medium volume).
    - **< 25%:** Returns "" (Low volume).
3. **Event Loop:** It subscribes to PulseAudio events using `pactl subscribe`. Whenever a "sink" event occurs (volume change, mute toggle), it outputs a new JSON line with the updated status.

## Dependencies

- `pulseaudio`: Provides `pactl`.
- `gnugrep`: For filtering volume data.
- `coreutils`: Standard utilities.

## Usage 

This script outputs a continuous stream of JSON objects to stdout.

```bash
prism-audio-status
```

## Output format

```JSON
{"icon": "", "percent": 75, "class": ""}
```