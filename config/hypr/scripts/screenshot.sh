#!/usr/bin/env bash
# Usage: screenshot.sh [full|region]
# Saves to ~/images/screenshots, copies to clipboard, and notifies.
dir="$HOME/images/screenshots"
mkdir -p "$dir"
file="$dir/$(date +'%Y-%m-%d_%H-%M-%S').png"

case "${1:-full}" in
  region)
    geom=$(slurp) || exit 0          # Esc/cancel -> exit quietly
    grim -g "$geom" "$file"
    ;;
  *)
    grim "$file"
    ;;
esac || { notify-send -u critical "Screenshot failed" "grim returned an error"; exit 1; }

wl-copy < "$file"
notify-send -i "$file" "Screenshot saved" "$file"
