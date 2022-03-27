fish_vi_key_bindings
set -g fish_greeting

set -gx XDG_CONFIG_HOME "/home/ayamir/.config"
set -gx EDITOR nvim
set -gx LANG en_US.UTF-8
set -U SXHKD_SHELL /usr/bin/bash

if status --is-interactive
	# Envs
	set -gx http_proxy "http://127.0.0.1:8889"
	set -gx https_proxy "http://127.0.0.1:8889"
	set -gx all_proxy "http://127.0.0.1:8889"
	
	abbr --add --global .. "cd ./.."
	abbr --add --global ... "cd ./../.."
	abbr --add --global .... "cd ./../../.."

	abbr --add --global vf "nvim ~/.config/fish/config.fish"
	abbr --add --global sf "source ~/.config/fish/config.fish"

	abbr --add --global ls "lsd"
	abbr --add --global l "exa -l --color=auto"
	abbr --add --global la "exa -alh --color=auto"

	abbr --add --global vc "nvim ~/.config/awesome/rc.lua"

	abbr --add --global py python3
	abbr --add --global pyins "pip3 install --user"
	abbr --add --global pyuins "pip3 uninstall"

	abbr --add --global ins "paru -S"
	abbr --add --global uins "paru -R"
	abbr --add --global up paru
	abbr --add --global c "paru -c"

	abbr --add --global stlsa "sudo systemctl start"
	abbr --add --global stlst "sudo systemctl stop"
	abbr --add --global stlsu "sudo systemctl status"
	abbr --add --global stlen "sudo systemctl enable"
	abbr --add --global stldis "sudo systemctl disable"
	abbr --add --global stlre "sudo systemctl restart"

	abbr --add --global og "git-open"
	abbr --add --global gu "gitui"
	abbr --add --global gc "git clone"
	abbr --add --global ga "git add"
	abbr --add --global gr "git restore ."
	abbr --add --global gm "git commit -m"
	abbr --add --global gps "git push"
	abbr --add --global gpl "git pull"

	abbr --add --global load "kill -USR1 (pidof st)"
	abbr --add --global use "xrdb merge"

	abbr --add --global clang++ "clang++ -std=c++2a"

	abbr --add --global dc "docker-compose"
	abbr --add --global dps "docker ps"
	abbr --add --global dst "docker stop"
	abbr --add --global dru "docker run"
	abbr --add --global drm "docker rm"
	abbr --add --global dls "docker images ls"

	abbr --add --global nv "nvim"
	abbr --add --global x "extract"
	abbr --add --global ne "neofetch"
	abbr --add --global rx "rxfetch"
	abbr --add --global mc "macchina"
	abbr --add --global uzw "unzip -O cp936"
	abbr --add --global ra "ranger"
	abbr --add --global d2u "find . -type f -exec dos2unix {} +"
	abbr --add --global del "sh ~/.rm.sh"
	abbr --add --global tra "cd ~/.local/share/Trash/files && ls -a"
	abbr --add --global cl "rm -rf ~/.local/share/Trash/files/*"
	abbr --add --global po "sudo poweroff"
	abbr --add --global reb "sudo reboot"
	abbr --add --global :q "exit"

	abbr --add --global hugo "hugo --enableGitInfo"
	abbr --add --global pb "hugo && hugo-algolia -s"
	abbr --add --global md "devour typora"
	abbr --add --global jn "jupyter notebook"

	abbr --add --global tl "timeleft"
end

zoxide init fish | source
