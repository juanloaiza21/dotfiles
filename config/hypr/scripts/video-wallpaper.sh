#!/usr/bin/env bash
# Video wallpapers: the 2 newest videos in ~/Downloads -> one per monitor (newest on DP-1).
# Falls back to hyprpaper (static) if mpvpaper isn't installed or no videos exist.
DIR="${1:-$HOME/Downloads}"
MONITORS=(DP-1 HDMI-A-1)

pkill -x mpvpaper; pkill -x hyprpaper
mapfile -t vids < <(find "$DIR" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' \) \
                    -printf '%T@ %p\n' | sort -rn | head -2 | cut -d' ' -f2-)

if ! command -v mpvpaper >/dev/null || [ ${#vids[@]} -eq 0 ]; then
  exec setsid hyprpaper
fi

for i in 0 1; do
  v="${vids[$i]:-${vids[0]}}"            # only one video -> reuse it
  setsid mpvpaper -o "no-audio loop hwdec=auto panscan=1.0" "${MONITORS[$i]}" "$v" >/dev/null 2>&1 &
done
