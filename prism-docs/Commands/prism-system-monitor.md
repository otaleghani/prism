# `prism-system-monitor`

A lightweight, continuous monitoring script that gathers real-time hardware telemetry. It is designed to act as a "data provider" for status bar widgets by outputting system health metrics in a structured JSON format. It handles CPU, RAM, Disk, and cross-vendor GPU (Nvidia/AMD) tracking.

## How it works

1. **CPU Tracking:** Instead of calling external tools, it reads `/proc/stat` directly. It calculates the delta between "total time" and "idle time" over a 2-second interval to provide an accurate percentage of CPU load.
2. **Temperature Sensing:** It utilizes `lm_sensors` and `jq` to parse hardware sensors. It automatically searches for the highest reported temperature input to identify the primary CPU heat source.
3. **Memory & Storage:**
    - **RAM:** Uses the `free` command, calculating the percentage of used memory relative to total capacity via `awk`.
    - **Disk:** Queries the root partition (`/`) using `df` to track storage consumption.
4. **Hybrid GPU Support:**
    - **Nvidia:** Uses `nvidia-smi` to query utilization and temperature if the binary is present.
    - **AMD:** Checks the kernel interface at `/sys/class/drm/card0/device/gpu_busy_percent` for usage and queries `sensors` for the "edge" temperature.
    - **Fallback:** Returns zeros if no supported discrete GPU is detected.
5. **Streaming Output:** The script runs an infinite loop, emitting a single line of minified JSON every 2 seconds.

## Dependencies

- `lm_sensors`: Provides `sensors` for temperature data.
- `jq`: Essential for parsing JSON output from sensors and constructing the final object.
- `procps`: Provides `free` and `top`.
- `coreutils`: Standard logic tools (`df`, `tail`, `read`).
- `nvidia-smi`: (Optional) Required for Nvidia GPU tracking.

## Usage

This script is intended to be run in the background by a TUI or GUI widget.

```bash
prism-system-monitor
```

## Sample JSON Output

```json
{
  "cpu": { "usage": 15, "temp": 42 },
  "ram": 28,
  "disk": 45,
  "gpu": { "usage": 10, "temp": 50 }
}
```