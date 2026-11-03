#!/usr/bin/env bash
# fastfetch with an ANIMATED gif as its logo. Must run inside kitty (kitty graphics protocol).
# fastfetch itself only draws still logos, so: fastfetch prints the info text (logo disabled,
# shifted right) and kitty's icat plays the gif in the reserved area on the left.
# Usage: rice-fetch.sh [full|strip]
MODE="${1:-full}"
GIF="${RICE_GIF:-$HOME/.config/fastfetch/images/rachael-hq.gif}"
CFG="$HOME/.config/fastfetch/rice.jsonc"
READY="${XDG_RUNTIME_DIR:-/tmp}/rice-layout-ready"

# Wait until the layout script finished opening panes (sizes are final), max 45s.
for _ in $(seq 1 90); do [ -e "$READY" ] && break; sleep 0.5; done
trap 'tput cnorm; stty echo 2>/dev/null; exit 0' INT TERM HUP

while :; do
  cols=$(tput cols); rows=$(tput lines)
  if [ "$MODE" = strip ]; then R=$((rows - 2)); [ $R -gt 9 ] && R=9; else R=$((rows - 4)); [ $R -gt 22 ] && R=22; fi
  [ $R -lt 4 ] && R=4
  C=$((R * 2)); pad=$((C + 4))
  clear; tput civis; stty -echo 2>/dev/null
  if [ "$MODE" = strip ]; then
    text=$(fastfetch -c "$CFG" --logo none --pipe false -s title:separator:os:kernel:uptime:cpu:gpu:memory:disk 2>/dev/null)
  else
    text=$(fastfetch -c "$CFG" --logo none --pipe false 2>/dev/null)
  fi
  printf '\n%s\n' "$text" | sed "s/^\(.\)/$(printf '%*s' "$pad" '')\1/"
  # kitty animates gifs natively; icat places it inside a cols x rows box (aspect preserved)
  kitten icat --clear --loop -1 --place "${C}x${R}@2x1" --transfer-mode=stream "$GIF"
  sleep 3600 & wait $!   # stay alive; resizing keeps the cell-anchored image in place
done
