#!/usr/bin/env bash
# Video wallpapers: the 2 newest videos in ~/Downloads -> one per monitor (newest on DP-1).
# Power saving: each video is converted ONCE to 1080p/30fps (cropped to 16:9, same crop mpv's
# panscan would do) and cached in ~/.cache/video-wallpapers; mpvpaper plays the light copy.
# Measured on RTX 3060 with two videos: 47 W -> 41 W, GPU use 16% -> 7%, CPU 9.7% -> 3%.
# NOTE: no mpvpaper -p (auto-pause): it pauses the video when a window covers the monitor.
# Falls back to hyprpaper (static) if mpvpaper isn't installed or no videos exist.
DIR="${1:-$HOME/Downloads}"
MONITORS=(DP-1 HDMI-A-1)
FPS="${WALLPAPER_FPS:-30}"
CACHE="$HOME/.cache/video-wallpapers"; mkdir -p "$CACHE"

pkill -x mpvpaper; pkill -x hyprpaper
mapfile -t vids < <(find "$DIR" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' \) \
                    -printf '%T@ %p\n' | sort -rn | head -2 | cut -d' ' -f2-)

if ! command -v mpvpaper >/dev/null || [ ${#vids[@]} -eq 0 ]; then
  exec setsid hyprpaper
fi

light_copy() { # original -> path of the cached light copy (or the original if conversion fails)
  local src="$1" key out
  key=$(stat -c '%n %Y %s' "$src" | sha1sum | cut -c1-12)
  out="$CACHE/$(basename "${src%.*}")-$key-1080p${FPS}.mp4"
  [ -s "$out" ] && { echo "$out"; return; }
  command -v ffmpeg >/dev/null || { echo "$src"; return; }
  local vf="fps=$FPS,scale=-2:1080,crop='min(iw,1920)':1080"
  local enc=(-c:v libx264 -preset veryfast -crf 23)
  ffmpeg -hide_banner -v error -encoders 2>/dev/null | grep -q h264_nvenc && enc=(-c:v h264_nvenc -preset p4 -cq 23)
  if ffmpeg -v error -y -i "$src" -vf "$vf" "${enc[@]}" -pix_fmt yuv420p -an -movflags +faststart "$out.part.mp4" </dev/null; then
    mv "$out.part.mp4" "$out"; echo "$out"
  else rm -f "$out.part.mp4"; echo "$src"; fi
}

for i in 0 1; do
  v="${vids[$i]:-${vids[0]}}"            # only one video -> reuse it
  play=$(light_copy "$v")
  setsid mpvpaper -o "no-audio loop panscan=1.0 hwdec=auto profile=fast interpolation=no cache=no" \
          "${MONITORS[$i]}" "$play" >/dev/null 2>&1 &
done
