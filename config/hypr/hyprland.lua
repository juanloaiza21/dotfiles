-- Hyprland 0.57+ Lua config.
-- Ported from the legacy hyprland.conf (kept alongside as hyprland.conf for reference).
-- Docs: https://wiki.hypr.land/configuring/

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "DP-1",     mode = "preferred",   position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@100", position = "1920x0", scale = 1 })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "alacritty"
local fileManager = "thunar"
local menu        = [[rofi -combi-modi window,drun,ssh -theme solarized -font "hack 10" -show combi -icon-theme "Papirus" -show-icons]]

-------------------------
---- WORKSPACE RULES ----
-------------------------

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1",     default = true })

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/waybar/launch.sh")
    hl.exec_cmd("~/.config/hypr/scripts/bar-autohide.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("~/.config/hypr/scripts/video-wallpaper.sh")      -- 2 newest videos in ~/Downloads
    hl.exec_cmd("protonvpn-app", { workspace = "1 silent" })      -- VPN (HDMI-A-1)
    hl.exec_cmd("zen", { workspace = "2 silent" })                -- browser (DP-1)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("WLR_DRM_DEVICES", "/dev/dri/card1")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(f725857e)", "rgba(f725857e)" }, angle = 45 },
            inactive_border = "rgba(3a0ca3fe)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 0.8,
        inactive_opacity = 0.65,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(f725857f)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },
})

-- Cyberpunk-inspired curves
hl.curve("cyberSlice", { type = "bezier", points = { {0.1, 0.9}, {0.1, 1.05} } })
hl.curve("neonPulse",  { type = "bezier", points = { {0.7, 0},   {0.3, 1}    } })
hl.curve("glitchOut",  { type = "bezier", points = { {0.1, 1.2}, {0.1, 0.9}  } })
hl.curve("quickShock", { type = "bezier", points = { {0.2, -0.2}, {0.1, 1.4} } })
hl.curve("synthWave",  { type = "bezier", points = { {0.3, -0.3}, {0.7, 1.2} } })

hl.animation({ leaf = "global",        enabled = true, speed = 7,   bezier = "synthWave" })
hl.animation({ leaf = "windows",       enabled = true, speed = 3.5, bezier = "cyberSlice" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.1, bezier = "glitchOut",  style = "popin 92%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.1, bezier = "quickShock", style = "popin 82%" })
hl.animation({ leaf = "border",        enabled = true, speed = 6.2, bezier = "neonPulse" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.3, bezier = "quickShock" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.2, bezier = "cyberSlice" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2.5, bezier = "synthWave" })
hl.animation({ leaf = "layers",        enabled = true, speed = 2.8, bezier = "glitchOut" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3.2, bezier = "neonPulse",  style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.4, bezier = "quickShock", style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.4, bezier = "quickShock" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.2, bezier = "glitchOut" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.5, bezier = "synthWave",  style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.1, bezier = "cyberSlice", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.3, bezier = "quickShock", style = "slidevert" })

hl.config({
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        mouse_move_enables_dpms = true,  -- any mouse move wakes screens that were turned off
        key_press_enables_dpms  = true,  -- any key press wakes them too
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = { natural_scroll = false },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("~/.config/hypr/scripts/screen-off.sh"))   -- screens off, processes keep running

-- Focus (WASD)
hl.bind(mainMod .. " + A", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + D", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + W", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + S", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + N",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh full"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region"))

-- Multimedia
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "ignore-empty-xwayland-popups",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_initial_focus = true,
})
