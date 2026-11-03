# dotfiles

Personal Arch Linux + Hyprland setup.

```
config/   -> ~/.config/<name>   (hypr, waybar, alacritty, kitty, rofi, nvim, ...)
home/     -> ~/.<file>          (.zshrc, .zshenv, .p10k.zsh, .gitconfig, .bashrc)
```

## Hyprland 0.57+ note
Hyprland 0.57 switched to a Lua config and **only reads `hypr/hyprland.lua`**.
If it's missing, it silently generates a default and ignores `hyprland.conf`.
`hyprland.conf` is kept only as the legacy reference. Validate edits without
touching the running session:

    Hyprland --verify-config --config ~/.config/hypr/hyprland.lua

hyprpaper / hypridle / hyprlock still use their `.conf` syntax.

## Login layout
`hypr/scripts/startup-layout.sh` (run from `hyprland.lua`):
- right screen (HDMI-A-1, ws 1): alacritty console + a pinned fastfetch/gif strip underneath
- left screen (DP-1, ws 2): fastfetch + animated gif / spotify / cmatrix / cava
- wallpapers: `video-wallpaper.sh` plays the 2 newest videos in `~/Downloads` with mpvpaper

The animated gif is drawn by kitty (`kitten icat`) because alacritty has no image protocol;
everything else uses alacritty. Needs: `mpvpaper` (AUR), `cava`, `cmatrix`, `kitty`, `spotify-launcher`, `jq`.
Gif (not in the repo): download it to `~/.config/fastfetch/images/rachael-hq.gif`
(https://gifdb.com/images/branded/high/blade-runner-rachael-pixel-m2ocp9s88n43p0ra.gif).

## Google Calendar in the bar
`waybar/scripts/calendar-events.py` shows upcoming events from your calendar's *secret iCal address*
(Google Calendar > Settings > your calendar > Integrate calendar). Save that URL, and only that URL, in
`~/.config/gcal/ics-url` (chmod 600). It is a password to your calendar: never commit it.

## Not included
- `alacritty/themes` -> `git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes`
- anything holding credentials (gh, gcloud, Postman, browser profiles, ...)

## Install (copy-based; back up first)
    cp -r config/* ~/.config/
    for f in home/.*; do [ -f "$f" ] && cp "$f" ~/; done
