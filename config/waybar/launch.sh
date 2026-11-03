#!/usr/bin/env bash
# Start one waybar process per monitor so each bar can be shown/hidden independently.
# Reads config.jsonc (comments allowed), injects "output", writes temp configs.
RT="${XDG_RUNTIME_DIR:-/tmp}/waybar-bars"; mkdir -p "$RT"
pkill -x waybar; sleep 0.3
for name in $(hyprctl monitors -j | jq -r '.[].name'); do
  python3 -I - "$HOME/.config/waybar/config.jsonc" "$name" "$RT/$name.json" <<'PY'
import sys, json
src, out_name, dst = sys.argv[1:]
s = open(src).read(); res = []; i = 0; in_str = False
while i < len(s):                      # strip // comments outside strings
    c = s[i]
    if in_str:
        res.append(c)
        if c == "\\": res.append(s[i+1]); i += 1
        elif c == '"': in_str = False
    elif c == '"': in_str = True; res.append(c)
    elif s.startswith("//", i):
        while i < len(s) and s[i] != "\n": i += 1
        continue
    else: res.append(c)
    i += 1
cfg = json.loads("".join(res)); cfg["output"] = out_name
json.dump(cfg, open(dst, "w"))
PY
  setsid waybar -c "$RT/$name.json" -s "$HOME/.config/waybar/style.css" >"$RT/$name.log" 2>&1 &
  echo $! >"$RT/$name.pid"
done
