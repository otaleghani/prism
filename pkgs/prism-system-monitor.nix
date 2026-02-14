{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.coreutils
    pkgs.gawk
    pkgs.gnugrep
    pkgs.lm_sensors # For CPU temps
    pkgs.jq
  ];
in
writeShellScriptBin "prism-system-monitor" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH

  # Helper: Get CPU Load (Non-blocking calculation)
  get_cpu() {
      # Read /proc/stat
      read -r cpu a b c idle rest < /proc/stat
      total=$((a+b+c+idle))
      
      # We need state to calculate delta, but for a simple stateless loop:
      # We rely on the fact that we loop. We store "prev" values in variables.
      
      # Initial calc (first run might be inaccurate, that's fine)
      if [ -z "$PREV_TOTAL" ]; then
          PREV_TOTAL=$total
          PREV_IDLE=$idle
          echo "0"
          return
      fi

      diff_total=$((total - PREV_TOTAL))
      diff_idle=$((idle - PREV_IDLE))
      
      # Avoid division by zero
      if [ "$diff_total" -eq 0 ]; then echo "0"; return; fi
      
      # Usage = ((Total - Idle) / Total) * 100
      # Integer arithmetic logic
      usage=$(( (1000 * (diff_total - diff_idle) / diff_total + 5) / 10 ))
      
      # Update prev
      PREV_TOTAL=$total
      PREV_IDLE=$idle
      
      echo "$usage"
  }

  # Helper: Get GPU (NVIDIA or AMD)
  get_gpu() {
      if command -v nvidia-smi &> /dev/null; then
          # Output: usage,temp
          nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F', ' '{printf "{\"usage\": %d, \"temp\": %d}", $1, $2}'
      elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
          # AMD
          usage=$(cat /sys/class/drm/card0/device/gpu_busy_percent)
          # Temp is harder on AMD without sensors, try generic hwmon
          temp=$(sensors -j 2>/dev/null | jq '.[].edge.temp1_input' 2>/dev/null | head -n1 | cut -d. -f1)
          echo "{\"usage\": $usage, \"temp\": ${"temp:-0"}}"
      else
          echo "{\"usage\": 0, \"temp\": 0}"
      fi
  }

  while true; do
      # 1. CPU Usage
      CPU_USAGE=$(get_cpu)
      
      # 2. CPU Temp (Try k10temp/coretemp via sensors)
      # We grab the highest reported "Package" or "Core" temp
      CPU_TEMP=$(sensors -j 2>/dev/null | jq 'max_by(.[] | objects | to_entries[] | select(.key | test("temp[0-9]+_input")) | .value) | .[] | objects | to_entries[] | select(.key | test("temp[0-9]+_input")) | .value' 2>/dev/null | cut -d. -f1)
      CPU_TEMP=${CPU_TEMP: -0} # Fallback to 0

      # 3. RAM Usage
      # free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }'
      RAM_USAGE=$(free | awk '/Mem/{printf("%.0f"), $3/$2*100}')
      
      # 4. Disk Usage (Root /)
      DISK_USAGE=$(df / --output=pcent | tail -n 1 | tr -d '% ')

      # 5. GPU
      GPU_JSON=$(get_gpu)

      # Output JSON
      echo "{\"cpu\": {\"usage\": $CPU_USAGE, \"temp\": $CPU_TEMP}, \"ram\": $RAM_USAGE, \"disk\": $DISK_USAGE, \"gpu\": $GPU_JSON}"
      
      sleep 2
  done
''
