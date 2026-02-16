{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils
    pkgs.gawk
    pkgs.gnugrep
    pkgs.lm_sensors
    pkgs.jq
    pkgs.procps
  ];
in
writeShellScriptBin "prism-system-monitor" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # State initialization
  # Stores previous CPU ticks to calculate utilization delta
  PREV_TOTAL=0
  PREV_IDLE=0

  while true; do
      # CPU utilization logic
      # Reads raw ticks from procfs and calculates the non-idle percentage
      read -r cpu a b c idle rest < /proc/stat
      TOTAL=$((a+b+c+idle))
      
      DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
      DIFF_IDLE=$((idle - PREV_IDLE))
      
      if [ "$DIFF_TOTAL" -eq 0 ]; then
          CPU_USAGE=0
      else
          CPU_USAGE=$(( (1000 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL + 5) / 10 ))
      fi
      
      PREV_TOTAL=$TOTAL
      PREV_IDLE=$idle

      # CPU temperature collection
      # Queries lm_sensors via JSON and selects the highest reported temperature
      CPU_TEMP=$(sensors -j 2>/dev/null | jq 'max_by(.[] | objects | to_entries[] | select(.key | test("temp[0-9]+_input")) | .value) | .[] | objects | to_entries[] | select(.key | test("temp[0-9]+_input")) | .value' 2>/dev/null | cut -d. -f1)
      CPU_TEMP=''${CPU_TEMP:-0}

      # Memory usage logic
      # Calculates percentage of used vs total physical RAM
      RAM_USAGE=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')
      
      # Storage metrics
      # Monitors capacity of the root filesystem
      DISK_USAGE=$(df / --output=pcent | tail -n 1 | tr -d '% ')

      # Graphics telemetry
      # Cross-platform detection for NVIDIA (smi) and AMD (sysfs) hardware
      if command -v nvidia-smi &> /dev/null; then
          GPU_JSON=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F', ' '{printf "{\"usage\": %d, \"temp\": %d}", $1, $2}')
      elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
          GPU_USAGE=$(cat /sys/class/drm/card0/device/gpu_busy_percent)
          GPU_TEMP_RAW=$(sensors -j 2>/dev/null | jq '.[].edge.temp1_input' 2>/dev/null | head -n1 | cut -d. -f1)
          GPU_JSON="{\"usage\": ''${GPU_USAGE:-0}, \"temp\": ''${GPU_TEMP_RAW:-0}}"
      else
          GPU_JSON="{\"usage\": 0, \"temp\": 0}"
      fi

      # Telemetry output
      # Streams structured JSON to stdout for easy parsing by status bars
      echo "{\"cpu\": {\"usage\": $CPU_USAGE, \"temp\": $CPU_TEMP}, \"ram\": $RAM_USAGE, \"disk\": $DISK_USAGE, \"gpu\": $GPU_JSON}"
      
      sleep 2
  done
''
