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

## Not included
- `alacritty/themes` -> `git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes`
- anything holding credentials (gh, gcloud, Postman, browser profiles, ...)

## Install (copy-based; back up first)
    cp -r config/* ~/.config/
    for f in home/.*; do [ -f "$f" ] && cp "$f" ~/; done
