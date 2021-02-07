#!/usr/bin/env bash

if [ $1 == "l" ]
then
    # Fcitx5
    sed -i "s/Gruvbox-Dark/Gruvbox-Light/g" ~/.config/fcitx5/conf/classicui.conf
    killall fcitx5
    # Wallpaper
    feh --bg-fill ~/Pictures/Background/linux-gruvbox-1920×1080.jpg
    # Dunst
    cp ~/.config/dunst/dunstrc-gruvbox-light ~/.config/dunst/dunstrc
    killall dunst
    # Rofi
    sed -i "s/grubox-dark/gruvbox-light/g" ~/.config/rofi/config.rasi
    # Dwm
    sed -i "s/col_gray1\[\]       \= \"\#282828\"/col_gray1\[\]       = \"\#fdf1c7\"/g" ~/.dwm/config.def.h
    sed -i "s/col_gray2\[\]       \= \"\#3c3836\"/col_gray2\[\]       = \"\#ebdbb2\"/g" ~/.dwm/config.def.h
    sed -i "s/col_gray3\[\]       \= \"\#ebdbb2\"/col_gray3\[\]       = \"\#3c3836\"/g" ~/.dwm/config.def.h
    sed -i "s/col_gray4\[\]       \= \"\#fdf1c7\"/col_gray4\[\]       = \"\#282828\"/g" ~/.dwm/config.def.h
    sed -i "s/col_cyan\[\]        \= \"\#d79921\"/col_cyan\[\]        = \"\#fabd2f\"/g" ~/.dwm/config.def.h
    source ~/.config/fish/functions/dwm_recompile.fish
    pkill -1 dwm
    # Alacritty
    cp ~/.config/alacritty/alacritty-gruvbox-light.yml ~/.config/alacritty/alacritty.yml
    # Kitty
    sed -i "s/dark/light/g" ~/.config/kitty/kitty.conf
    # Fish
    fish -c gruvbox_light
    # Global theme
    sed -i "s/Gruvbox-Material-Dark/Pop-gruvbox/g" ~/.config/xsettingsd/xsettingsd.conf
    sed -i 's/Gruvbox-Material-Dark/Pop-gruvbox/g' ~/.gtkrc-2.0
    sed -i "s/Gruvbox-Material-Dark/Pop-gruvbox/g" ~/.config/gtk-3.0/settings.ini
    pkill -1 xsettingsd
    # Vim
    sed -i "s/background\=dark/background\=light/g" ~/.vimrc
    # Emacs
    sed -i "s/doom-gruvbox)/doom-gruvbox-light)/g" ~/.doom.d/config.el
    emacsclient -e '(kill-emacs)'
    # Code
    sed -i "s/Gruvbox Material Dark/Gruvbox Material Light/g" ~/.config/Code/User/settings.json
    # Sublime
    sed -i "s/Dark/Light/g" ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
    # Zathura
    cp ~/.config/zathura/zathurarc-gruvbox-light ~/.config/zathura/zathurarc
    # Daemons
    sh ~/.local/bin/startdaemon
    # Notify
    notify-send "Switch to Light Now!" -t 3000
elif [ $1 == "n" ]
then
    # Fcitx5
    sed -i "s/Gruvbox-Light/Gruvbox-Dark/g" ~/.config/fcitx5/conf/classicui.conf
    killall fcitx5
    # Wallpaper
    feh --bg-fill ~/Pictures/Background/gruvbox_pacman.png
    # Dunst
    cp ~/.config/dunst/dunstrc-gruvbox-dark ~/.config/dunst/dunstrc
    killall dunst
    # Rofi
    sed -i "s/grubox-light/gruvbox-dark/g" ~/.config/rofi/config.rasi
    # Dwm
    sed -i "s/col_gray1\[\]       \= \"\#fdf1c7\"/col_gray1\[\]       = \"\#282828\"/g" ~/.dwm/config.def.h
    sed -i "s/col_gray2\[\]       \= \"\#ebdbb2\"/col_gray2\[\]       = \"\#3c3836\"/g" ~/.dwm/config.def.h
    sed -i "s/col_gray3\[\]       \= \"\#3c3836\"/col_gray3\[\]       = \"\#ebdbb2\"/g" ~/.dwm/config.def.h
    sed -i "s/col_gray4\[\]       \= \"\#282828\"/col_gray4\[\]       = \"\#fdf1c7\"/g" ~/.dwm/config.def.h
    sed -i "s/col_cyan\[\]        \= \"\#fabd2f\"/col_cyan\[\]        = \"\#d79921\"/g" ~/.dwm/config.def.h
    source ~/.config/fish/functions/dwm_recompile.fish
    pkill -1 dwm
    # Alacritty
    cp ~/.config/alacritty/alacritty-gruvbox-dark.yml ~/.config/alacritty/alacritty.yml
    # Kitty
    sed -i "s/light/dark/g" ~/.config/kitty/kitty.conf
    # Fish
    fish -c gruvbox_dark
    # Global theme
    sed -i "s/Pop-gruvbox/Gruvbox-Material-Dark/g" ~/.config/xsettingsd/xsettingsd.conf
    sed -i 's/Pop-gruvbox/Gruvbox-Material-Dark/g' ~/.gtkrc-2.0
    sed -i "s/Pop-gruvbox/Gruvbox-Material-Dark/g" ~/.config/gtk-3.0/settings.ini
    pkill -1 xsettingsd
    # Vim
    sed -i "s/background\=light/background\=dark/g" ~/.vimrc
    # Emacs
    sed -i 's/doom-gruvbox-light)/doom-gruvbox)/g' ~/.doom.d/config.el
    emacsclient -e '(kill-emacs)'
    # Code
    sed -i "s/Gruvbox Material Light/Gruvbox Material Dark/g" ~/.config/Code/User/settings.json
    # Sublime
    sed -i "s/Light/Dark/g" ~/.config/sublime-text-3/Packages/User/Preferences.sublime-settings
    # Zathura
    cp ~/.config/zathura/zathurarc-gruvbox-dark ~/.config/zathura/zathurarc
    # Daemons
    sh ~/.local/bin/startdaemon
    # Notify
    notify-send "Switch to Dark Now!" -t 3000
fi

kitty --class kitty-reload --single-instance -e kitty_reload_x
