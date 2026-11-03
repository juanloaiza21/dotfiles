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

## Startup
`hyprland.lua` autostarts: waybar (one process per monitor), the bar auto-hide watcher, hypridle,
video wallpapers, Proton VPN (ws 1 / HDMI-A-1) and the Zen browser (ws 2 / DP-1).

Wallpapers: `hypr/scripts/video-wallpaper.sh` plays the 2 newest videos in `~/Downloads` with
mpvpaper (AUR), converting each once to a light 1080p/30fps copy in `~/.cache/video-wallpapers`.

(A 4-pane "rice" login layout with an animated-gif fastfetch existed in earlier commits and was
removed; see `git log` if you want it back.)

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
