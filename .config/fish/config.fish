# Paths
set PATH $PATH $HOME/.local/bin
set -xg GOROOT /usr/lib/go
set -xg GOPATH $HOME/go
set -xg GOBIN $HOME/go/bin
set -xg http_proxy "http://127.0.0.1:8889"
set -xg all_proxy "http://127.0.0.1:8889"

set -x EDITOR nvim

set -xg GLFW_IM_MODULE "ibus"
set -xg XDG_CONFIG_HOME "/home/ayamir/.config"

set -U FZF_LEGACY_KEYBINDINGS 0
set -U SXHKD_SHELL /usr/bin/bash

# Init

# Aliases
alias vf "nvim ~/.config/fish/config.fish"
alias sf "source ~/.config/fish/config.fish"
alias l "ll"
alias cs "sh /opt/shell-color-scripts/colorscript.sh -r"

alias jg "cd ~/git"
alias jgs "cd ~/go/src/learn/book"
alias jc "cd ~/.config"
alias jd "cd ~/Downloads"
alias jdc "cd ~/Downloads/Compressed"
alias jcl "cd ~/clone"

alias vp "nvim ~/.config/picom/picom.conf"
alias vsp "nvim ~/.config/spectrwm/spectrwm.conf"
alias vsb "nvim ~/.config/spectrwm/baraction.sh"
alias v3 "nvim ~/.config/i3/config"
alias vw "nvim ~/.config/sway/config"
alias vx "nvim ~/.xmonad/xmonad.hs"
alias vb "nvim ~/.config/bspwm/bspwmrc"
alias vs "nvim ~/.config/sxhkd/sxhkdrc"
alias vc "cd ~/.dwm/; nvim ~/.dwm/config.def.h"
alias vv "nvim ~/.vimrc"
alias vvc "nvim ~/.vimrc.custom.config"
alias vvp "nvim ~/.vimrc.custom.plugins"

alias pyins "pip3 install --user"
alias pyuins "pip3 uninstall"

alias inss "sh ~/.local/bin/land && sudo pacman -S"
alias ins "sh ~/.local/bin/land && yay -S"
alias uins "sudo pacman -R"
alias uinss "sudo pacman -Rsc"
alias key "sudo pacman -S archlinuxcn-keyring"
alias up "sh ~/.local/bin/land && yay -Syyu"

alias stlsa "sudo systemctl start"
alias stlsu "sudo systemctl status"
alias stlst "sudo systemctl stop"
alias stlre "sudo systemctl restart"
alias stlen "sudo systemctl enable --now"
alias stldis "sudo systemctl disable"

alias gc "git clone"
alias ga "git add"
alias gm "git commit -m"
alias gps "git push"

alias doom "~/.emacs.d/bin/doom"
alias ew "emacsclient -nw"
alias vi "vim"
alias vim "nvim"
alias nano "micro"
alias sudo "sudo"

alias ls "logo-ls"
alias x "extract"
alias mu "land && musicbox"
alias ne "neofetch"
alias uzw "unzip -O cp936"
alias ra "ranger"
alias del "sh ~/.rm.sh"
alias tra "cd ~/.local/share/Trash/files && ls -a"
alias po "poweroff"
alias reb "reboot"

kitty + complete setup fish | source
starship init fish | source
