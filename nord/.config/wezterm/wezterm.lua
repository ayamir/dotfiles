local wezterm = require "wezterm"
local mykeys = {
    {
        key = "t",
        mods = "SHIFT|ALT",
        action = wezterm.action {SpawnTab = "CurrentPaneDomain"}
    }, {
        key = "w",
        mods = "SHIFT|ALT",
        action = wezterm.action {CloseCurrentTab = {confirm = true}}
    }, {key = "=", mods = "CTRL", action = "IncreaseFontSize"},
    {key = "-", mods = "CTRL", action = "DecreaseFontSize"},
    {key = "0", mods = "CTRL", action = "ResetFontSize"},
    {key = "C", mods = "CTRL|SHIFT", action = "Copy"},
    {key = "V", mods = "CTRL|SHIFT", action = "Paste"},
    {key = "Z", mods = "CTRL", action = "TogglePaneZoomState"}, {
        key = "J",
        mods = "SHIFT|ALT",
        action = wezterm.action {ActivateTabRelative = -1}
    }, {
        key = "K",
        mods = "SHIFT|ALT",
        action = wezterm.action {ActivateTabRelative = 1}
    }, {key = "X", mods = "SHIFT|ALT", action = "ActivateCopyMode"},
    {key = " ", mods = "SHIFT|ALT", action = "QuickSelect"}
}
for i = 1, 8 do
    table.insert(mykeys, {
        key = tostring(i),
        mods = "CTRL|ALT",
        action = wezterm.action {ActivateTab = i - 1}
    })
end

return {
    use_ime = true,
    default_prog = {"/usr/bin/zsh", "-l"},
    font = wezterm.font_with_fallback({
        "JetBrainsMono Nerd Font", "Sarasa Mono SC Nerd", "FiraCode Nerd Font",
        "BlexMono Nerd Font"
    }),
    front_end = "OpenGL",
    font_size = 12,
    color_scheme = "nord",
    enable_tab_bar = true,
    tab_max_width = 20,
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    colors = {
        tab_bar = {
            background = "#2e3440",
            active_tab = {
                bg_color = "#5e81ac",
                fg_color = "#eceff4",
                intensity = "Bold",
                italic = true
            },
            inactive_tab = {bg_color = "#4c566a", fg_color = "#d8dee9"},
            inactive_tab_hover = {
                bg_color = "#d8dee9",
                fg_color = "#3b4252",
                italic = false
            },
            new_tab = {bg_color = "#3b4252", fg_color = "#a3be8c"},
            new_tab_hover = {
                bg_color = "#3b4252",
                fg_color = "#8fbcbb",
                italic = false
            }
        }
    },
    text_background_opacity = 1.0,
    disable_default_key_bindings = true,
    mouse_bindings = {
        {

            event = {Up = {streak = 1, button = "Left"}},
            mods = "NONE",
            action = wezterm.action {
                CompleteSelectionOrOpenLinkAtMouseCursor = "Clipboard"
            }
        }, {
            event = {Up = {streak = 1, button = "Left"}},
            mods = "CTRL",
            action = "OpenLinkAtMouseCursor"
        }
    },
    keys = mykeys,
    window_background_opacity = 0.95
    -- window_background_image = "/home/ayamir/Pictures/wezterm/nord.jpg",
    -- window_background_image_hsb = {
    --     brightness = 2.0,
    --     hue = 1.0,
    --     saturation = 1.0
    -- }
}
