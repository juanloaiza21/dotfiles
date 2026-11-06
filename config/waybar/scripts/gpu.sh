#!/usr/bin/env bash
# NVIDIA GPU module for waybar: usage + temp, tooltip with VRAM.
out=$(nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total \
      --format=csv,noheader,nounits 2>/dev/null) || { echo '{"text":"󰢮 --","tooltip":"nvidia-smi unavailable"}'; exit 0; }
IFS=',' read -r name util temp used total <<<"$out"
name=$(echo "$name" | xargs); util=$(echo "$util" | xargs); temp=$(echo "$temp" | xargs)
used=$(echo "$used" | xargs); total=$(echo "$total" | xargs)
class=""
[ "$temp" -ge 80 ] && class="critical"
[ -z "$class" ] && [ "$temp" -ge 70 ] && class="warning"
printf '{"text":"󰢮 %s%%","tooltip":":: %s\\nUsage: %s%%\\nTemp: %s°C\\nVRAM: %s / %s MiB","class":"%s"}\n' \
  "$util" "$name" "$util" "$temp" "$used" "$total" "$class"
