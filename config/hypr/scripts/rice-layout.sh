#!/usr/bin/env bash
# Opens the 4-pane "rice" layout on one workspace (default 2 = DP-1):
#   [ fastfetch ][ spotify ]
#   [  cmatrix  ][  cava   ]
# Usage: rice-layout.sh [workspace]
WS="${1:-2}"
READY="${XDG_RUNTIME_DIR:-/tmp}/rice-layout-ready"
[ -z "$RICE_MANAGED" ] && rm -f "$READY"
hc() { hyprctl dispatch "$1" >/dev/null 2>&1; }
open() { # command class  -> exec on $WS without stealing focus
  hc "hl.dsp.exec_cmd([[$1]], { workspace = \"$WS silent\" })"
}
addr_of() { # class -> address (waits up to ~25s)
  local a
  for _ in $(seq 1 125); do
    a=$(hyprctl clients -j | jq -r --arg c "$1" '[.[]|select(.class==$c)][0].address // empty')
    [ -n "$a" ] && { echo "$a"; return 0; }; sleep 0.2
  done; return 1
}
focus() { hc "hl.dsp.focus({ window = \"address:$1\" })"; }
split() { hc "hl.dsp.layout(\"preselect $1\")"; }

# 1) fastfetch (top-left)
open "kitty --class rice-fetch -o background_opacity=1 -e $HOME/.config/hypr/scripts/rice-fetch.sh full"
FETCH=$(addr_of rice-fetch) || exit 1

# 2) spotify to the right
focus "$FETCH"; split r
open "spotify-launcher"
SPOT=$(addr_of Spotify)

# 3) cava under spotify
if [ -n "$SPOT" ]; then focus "$SPOT"; split d; fi
open "alacritty --class rice-cava -e cava -p $HOME/.config/cava/config"
addr_of rice-cava >/dev/null

# 4) cmatrix under fastfetch
focus "$FETCH"; split d
open "alacritty --class rice-matrix -e cmatrix -a -b -C magenta"
addr_of rice-matrix >/dev/null

touch "$READY"   # tells the gif panes sizes are final
