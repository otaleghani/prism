# `prism-audio-mixer`

The backend logic for the Prism audio control panel (built with QuickShell). This script acts as a bridge between the system's PulseAudio server and the UI. It handles two primary functions: continuously broadcasting the system audio state (volumes, active apps, available devices) in JSON format and executing commands to modify that state.

## How it works

1. **State Aggregation (`get_state`):**
    - Queries `pactl` to find the default sink (speaker/headphones).
    - Parses the master volume and mute status.
    - Iterates through all available **Sinks** (output devices) and **Sink Inputs** (applications playing audio).
    - Assigns icons to applications based on their name (e.g., Spotify gets a specific icon, browsers get another).        
    - Outputs a single JSON object containing all this data.
2. **Event Loop (`listen` mode):**
    - Subscribes to PulseAudio events using `pactl subscribe`.
    - To prevent high CPU usage from rapid-fire events (e.g., sliding a volume bar), it uses a "trigger file" approach. Events write to `/tmp/prism_audio_trigger`.
    - A separate loop checks this file every 0.1 seconds. If the file is not empty, it clears the file and pushes a new JSON state update.
3. **Control Commands:** It accepts specific arguments to change volumes, mute status, or switch output devices.

## Dependencies

- `pulseaudio`: Provides `pactl` for querying and controlling the audio server.
- `jq`: formats the raw audio data into clean JSON for the UI.
- `gnugrep`, `coreutils`, `procps`: Standard text processing and process management tools.

## Usage

This script is primarily called by the QuickShell UI widgets, not manually by the user.

```bash
prism-audio-mixer <command> [args...]
```

## Commands
|**Command**|**Arguments**|**Description**|
|---|---|---|
|`listen`|_None_|Starts the event loop, printing JSON state updates to stdout.|
|`set-volume`|`<id> <vol>`|Sets the volume of a specific application (sink-input ID) to `<vol>%`.|
|`set-master`|`<vol>`|Sets the default sink's volume to `<vol>%`.|
|`toggle-mute`|_None_|Toggles the mute state of the default sink.|
|`set-default`|`<sink_name>`|Sets the default output device and **moves all currently playing audio** to it.|
## JSON Output Structure (Listen Mode)
When running in `listen` mode, the script outputs a JSON object with the following schema:

```JSON
{
  "master": { "vol": 75, "muted": false },
  "sinks": [
    { "id": 0, "name": "...", "desc": "Headphones", "vol": 75, "is_default": true }
  ],
  "apps": [
    { "id": 12, "name": "Spotify", "vol": 100, "icon": "" }
  ]
}
```

## Integration Notes

- **UI Toggle:** The [[03 QuickShell]] mixer panel associated with this script is toggled by touching the file `/tmp/prism-drawer-volume`.
- **Performance:** The 0.1s debounce in the listener loop ensures the UI remains responsive without spamming the audio server with queries during volume slides.