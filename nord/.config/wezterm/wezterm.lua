local wezterm = require "wezterm"
return {
    default_prog = {"/usr/bin/fish", "-l"},
    font = wezterm.font_with_fallback(
        {
            "JetBrainsMono Nerd Font",
            "Sarasa Mono SC Nerd",
            "FiraCode Nerd Font"
        }
    ),
    front_end = "OpenGL",
    font_size = 12,
    color_scheme = "OneHalfLight",
    enable_tab_bar = false,
    text_background_opacity = 0.1,
    window_background_image = "/home/ayamir/Pictures/wezterm/OneHalfLight.jpg",
    window_background_image_hsb = {
        brightness = 1.0,
        hue = 1.0,
        saturation = 1.0
    }
}
