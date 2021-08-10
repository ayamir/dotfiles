local wezterm = require 'wezterm';
return {
    default_prog = {"/usr/bin/fish", "-l"},
    font = wezterm.font_with_fallback({
        "JetBrainsMono Nerd Font", "Sarasa Mono SC Nerd", "FiraCode Nerd Font"
    }),
    front_end = "OpenGL",
    font_size = 12,
    color_scheme = "nord",
    enable_tab_bar = false,
    text_background_opacity = 0.90,
    window_background_image = "/home/ayamir/Pictures/wezterm/nord.jpg",

    window_background_image_hsb = {
        brightness = 0.9,
        hue = 1.0,
        saturation = 1.0
    }
}
