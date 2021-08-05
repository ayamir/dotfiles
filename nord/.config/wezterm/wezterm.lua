local wezterm = require 'wezterm';
return {
    default_prog = {"/usr/bin/zsh", "-l"},
    font = wezterm.font_with_fallback({
        "JetBrainsMono Nerd Font", "Sarasa Mono SC Nerd", "FiraCode Nerd Font"
    }),
    color_scheme = "nord",
    enable_tab_bar = false,
    text_background_opacity = 0.8
}
