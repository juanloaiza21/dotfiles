#!/usr/bin/env bash
# Per-monitor auto-hide: a monitor's bar hides only while ITS workspace is fullscreen,
# and reappears when the cursor touches that monitor's top edge.
# Needs waybar started by ~/.config/waybar/launch.sh (one process per monitor, pidfiles).
EDGE=3; KEEP=48
RT="${XDG_RUNTIME_DIR:-/tmp}/waybar-bars"

decide() { # y fs shown -> show|hide|keep
  local y=$1 fs=$2 shown=$3
  if [ "$fs" -eq 0 ]; then [ "$shown" -eq 1 ] && echo keep || echo show; return; fi
  if [ "$y" -le "$EDGE" ]; then [ "$shown" -eq 1 ] && echo keep || echo show
  elif [ "$y" -gt "$KEEP" ]; then [ "$shown" -eq 0 ] && echo keep || echo hide
  else echo keep; fi
}
[ "$1" = "--decide" ] && { decide "$2" "$3" "$4"; exit 0; }

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/bar-autohide.lock"; flock -n 9 || exit 0
declare -A shown
while true; do
  cur=$(hyprctl cursorpos -j); mons=$(hyprctl monitors -j); wss=$(hyprctl workspaces -j)
  while read -r name fs rely; do
    [ -z "$name" ] && continue
    s=${shown[$name]:-1}
    act=$(decide "$rely" "$fs" "$s")
    pid=$(cat "$RT/$name.pid" 2>/dev/null)
    [ -n "$pid" ] || continue
    case $act in
      show) kill -USR1 "$pid" 2>/dev/null; shown[$name]=1 ;;
      hide) kill -USR2 "$pid" 2>/dev/null; shown[$name]=0 ;;
    esac
  done < <(jq -n -r --argjson c "$cur" --argjson m "$mons" --argjson w "$wss" '
    $m[] | . as $mon
    | ([$w[] | select(.id == $mon.activeWorkspace.id) | .hasfullscreen][0] // false) as $fs
    | (if ($c.x >= $mon.x and $c.x < $mon.x + $mon.width and $c.y >= $mon.y and $c.y < $mon.y + $mon.height)
       then ($c.y - $mon.y) else 9999 end) as $rely
    | "\($mon.name) \(if $fs then 1 else 0 end) \($rely | floor)"')
  sleep 0.15
done
