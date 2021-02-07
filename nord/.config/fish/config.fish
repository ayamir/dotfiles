# Paths
set PATH $PATH $HOME/.local/bin
set -xg GOROOT /usr/lib/go
set -xg GOPATH $HOME/go
set -xg GOBIN $HOME/go/bin
set -xg http_proxy "http://127.0.0.1:8889"
set -xg all_proxy "http://127.0.0.1:8889"

set -x EDITOR nvim

#set -xg WAYLAND_DISPLAY wayland-0
set -U FZF_LEGACY_KEYBINDINGS 0

# Aliases
alias vf "nvim ~/.config/fish/config.fish"
alias sf "source ~/.config/fish/config.fish"
alias l "ll"
alias cs "sh /opt/shell-color-scripts/colorscript.sh -e"

alias jg "cd ~/git"
alias jb "cd ~/git/bspwm-dotfiles"
alias ji "cd ~/git/i3-dotfiles"
alias jx "cd ~/git/xmonad-dotfiles"
alias jc "cd ~/.config"
alias jd "cd ~/Downloads"
alias jdc "cd ~/Downloads/Compressed"
alias jcl "cd ~/clone"

alias vp "nvim ~/.config/picom/picom.conf"
alias v3 "nvim ~/.config/i3/config"
alias vw "nvim ~/.config/sway/config"
alias vx "nvim ~/.xmonad/xmonad.hs"
alias vb "nvim ~/.config/bspwm/bspwmrc"
alias vs "nvim ~/.config/sxhkd/sxhkdrc"
alias vv "nvim ~/.vimrc"
alias vvc "nvim ~/.vimrc.custom.config"
alias vvp "nvim ~/.vimrc.custom.plugins"

alias pyins "pip3 install --user"
alias pyuins "pip3 uninstall"

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

alias vim "nvim"
alias c "clear"
alias x "extract"
alias ne "neofetch"
alias uzw "unzip -O cp936"
alias ra "ranger"
alias del "sh ~/.rm.sh"
alias tra "cd ~/.local/share/Trash/files && ls -a"
alias po "sh ~/.config/sxhkd/reset.sh && poweroff"
alias reb "sh ~/.config/sxhkd/reset.sh && reboot"

starship init fish | source
