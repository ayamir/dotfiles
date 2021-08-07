local wezterm = require 'wezterm';
return {
    default_prog = {"/usr/bin/zsh", "-l"},
    font = wezterm.font("JetBrainsMono Nerd Font", {weight = "Regular"}),
    front_end = "OpenGL",
    font_size = 12,
    color_scheme = "OneHalfLight",
    enable_tab_bar = false,
    text_background_opacity = 0.8,
    window_background_opacity = 0.8
}
