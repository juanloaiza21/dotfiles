#!/usr/bin/env bash
# Auto-hide waybar while a window is fullscreen; reveal when the cursor hits the
# top edge of that monitor. Waybar must be configured with:
#   "layer": "overlay", "on-sigusr1": "show", "on-sigusr2": "hide"
# Usage: bar-autohide.sh            (run the watcher)
#        bar-autohide.sh --decide <cursor_y_rel> <fullscreen 0|1> <currently_shown 0|1>   (dry run)
EDGE=3        # px from top that triggers reveal
KEEP=48       # px: keep bar shown while cursor is within this distance

decide() { # cursor_y_rel fullscreen shown -> prints show|hide|keep
  local y=$1 fs=$2 shown=$3
  if [ "$fs" -eq 0 ]; then [ "$shown" -eq 1 ] && echo keep || echo show; return; fi
  if [ "$y" -le "$EDGE" ]; then [ "$shown" -eq 1 ] && echo keep || echo show
  elif [ "$y" -gt "$KEEP" ]; then [ "$shown" -eq 0 ] && echo keep || echo hide
  else echo keep; fi
}

if [ "$1" = "--decide" ]; then decide "$2" "$3" "$4"; exit 0; fi

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/bar-autohide.lock"
flock -n 9 || exit 0     # single instance

shown=1
while true; do
  read -r cx cy < <(hyprctl cursorpos -j | jq -r '"\(.x) \(.y)"')
  mon=$(hyprctl monitors -j | jq -c --argjson x "${cx:-0}" --argjson y "${cy:-0}" \
        '.[] | select(.x<=$x and $x<(.x+.width) and .y<=$y and $y<(.y+.height))')
  if [ -n "$mon" ]; then
    my=$(jq -r '.y' <<<"$mon"); wsid=$(jq -r '.activeWorkspace.id' <<<"$mon")
    fs=$(hyprctl workspaces -j | jq -r --argjson id "$wsid" '[.[]|select(.id==$id)|.hasfullscreen][0] // false | if . then 1 else 0 end')
    act=$(decide $((cy - my)) "$fs" "$shown")
    case $act in
      show) pkill -SIGUSR1 -x waybar; shown=1 ;;
      hide) pkill -SIGUSR2 -x waybar; shown=0 ;;
    esac
  fi
  sleep 0.15
done
