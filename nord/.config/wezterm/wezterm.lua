local wezterm = require "wezterm"
local mykeys = {
    {
        key = "t",
        mods = "CTRL|SHIFT",
        action = wezterm.action {SpawnTab = "CurrentPaneDomain"}
    }, {
        key = "w",
        mods = "CTRL|SHIFT",
        action = wezterm.action {CloseCurrentTab = {confirm = false}}
    }, {key = "=", mods = "CTRL", action = "IncreaseFontSize"},
    {key = "-", mods = "CTRL", action = "DecreaseFontSize"},
    {key = "0", mods = "CTRL", action = "ResetFontSize"},
    {key = "C", mods = "CTRL|SHIFT", action = "Copy"},
    {key = "V", mods = "CTRL|SHIFT", action = "Paste"},
    {key = "Z", mods = "CTRL", action = "TogglePaneZoomState"}
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
    default_prog = {"/usr/bin/fish", "-l"},
    font = wezterm.font_with_fallback({
        "JetBrainsMono Nerd Font", "Sarasa Mono SC Nerd", "FiraCode Nerd Font"
    }),
    front_end = "OpenGL",
    font_size = 12,
    color_scheme = "OneHalfLight",
    enable_tab_bar = true,
    text_background_opacity = 0.9,
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
    keys = mykeys
}
