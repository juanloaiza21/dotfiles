#!/usr/bin/env bash
# Login layout.
#   right screen (workspace $1, default 1): console on top + pinned fastfetch/gif strip below
#   left  screen (workspace $2, default 2): fastfetch+gif / spotify / cmatrix / cava (rice-layout.sh)
CON_WS="${1:-1}"; RICE_WS="${2:-2}"
READY="${XDG_RUNTIME_DIR:-/tmp}/rice-layout-ready"; rm -f "$READY"
S="$HOME/.config/hypr/scripts"
hc() { hyprctl dispatch "$1" >/dev/null 2>&1; }
open() { hc "hl.dsp.exec_cmd([[$1]], { workspace = \"$2 silent\" })"; }
addr_of() { local a; for _ in $(seq 1 100); do
  a=$(hyprctl clients -j | jq -r --arg c "$1" '[.[]|select(.class==$c)][0].address // empty'); [ -n "$a" ] && { echo "$a"; return 0; }; sleep 0.2; done; return 1; }
focus() { hc "hl.dsp.focus({ window = \"address:$1\" })"; }

# --- right screen: console + strip
open "alacritty --class console" "$CON_WS"
CON=$(addr_of console) || exit 1
focus "$CON"; hc 'hl.dsp.layout("preselect d")'
open "kitty --class rice-strip -o background_opacity=1 -e $S/rice-fetch.sh strip" "$CON_WS"
STRIP=$(addr_of rice-strip) && { focus "$STRIP"; hc 'hl.dsp.window.resize({ x = 0, y = 230, relative = true })'; }

# --- left screen: the 4-pane layout (touches $READY when done)
RICE_MANAGED=1 "$S/rice-layout.sh" "$RICE_WS"

# leave focus in the console so you can type right away
focus "$CON"
