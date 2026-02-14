# `prism-screenrecord`

A high-performance screen recording utility tailored for Prism. It leverages `gpu-screen-recorder` for hardware-accelerated recording (minimal CPU impact) and provides advanced features like multi-source audio mixing and a real-time webcam overlay. It is designed to work seamlessly with [[Hyprland]].

## How it works

1. **Hardware Acceleration:** Uses your GPU to encode video at 60 FPS, ensuring that recording a game or a heavy application doesn't cause system lag.
2. **Webcam Overlay (`ffplay`):** * Automatically detects your camera device via `v4l-utils`.
    - Calculates the correct window size based on your monitor's HiDPI scale (querying `hyprctl`).
    - Launches a frameless, low-latency preview window titled "WebcamOverlay."
3. **Audio Management:** Can simultaneously capture desktop audio and microphone audio by dynamically building the recording command.
4. **Wayland Integration:** Uses `xdg-desktop-portal` to allow you to select a specific window, monitor, or region for recording.
5. **Toggle Logic:** The script acts as a toggle. If it's already running, it stops and saves the video. If not, it begins a new session. It also signals `waybar` to update recording status icons.    

## Dependencies

- `gpu-screen-recorder`: The core recording engine.
- `ffmpeg`: Specifically `ffplay` for the webcam preview.
- `v4l-utils`: For camera hardware detection.
- `hyprland`: To ensure window rules and scaling are handled correctly.
- `libnotify`: For start/stop status notifications.

## Usage

```bash
prism-screenrecord [options]
```

## Options

|**Flag**|**Description**|
|---|---|
|`--desktop`|Include system/desktop audio in the recording.|
|`--mic`|Include microphone audio in the recording.|
|`--webcam`|Open a webcam overlay window before starting.|
|`--device=/dev/videoX`|Manually specify which webcam device to use.|
|`--stop`|Forces any active recording or webcam session to end.|

## Example: Streamer Mode

Record with desktop sound, your microphone, and your face on screen:

```bash
prism-screenrecord --desktop --mic --webcam
```

## Workflow & Integration

- **Output Path:** Videos are saved to `~/Videos` (or your XDG defined Videos folder) with a timestamped filename: `Recording_YYYY-MM-DD_HH-MM-SS.mp4`.
- **Window Rules:** Prism comes pre-configured with Hyprland rules for the "WebcamOverlay" class to ensure your face stays pinned and floating above other windows.