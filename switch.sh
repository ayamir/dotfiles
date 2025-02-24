#!/usr/bin/env bash

input=$1
nvim_setting=~/.config/nvim/lua/user/settings.lua

check_file_exists() {
	if [ ! -f "$1" ]; then
		exit 1
	fi
}

kill_process() {
	pid=$1
	if [ -n "$pid" ]; then
		kill -SIGUSR1 "$pid"
	fi
}

set_neovim_background() {
	background=$1
	servers=$(lsof -U | grep nvim | grep /run/user | awk '{print $9}')
	for server in $servers; do
		nvim --server $server --remote-send ":set background=$background<CR>"
	done
}

if [ "$input" == "light" ]; then
	check_file_exists ~/.tmux.conf.light
	check_file_exists ~/.config/kitty/kitty.conf.light

	ln -sf ~/.tmux.conf.light ~/.tmux.conf
	ln -sf ~/.config/kitty/kitty.conf.light ~/.config/kitty/kitty.conf
	sed -i 's/settings\["background"\] = "dark"/settings\["background"\] = "light"/' "$nvim_setting"

	kill_process $(pgrep kitty)
	set_neovim_background "light"
	tmux source-file ~/.tmux.conf

elif [ "$input" == "dark" ]; then
	check_file_exists ~/.tmux.conf.dark
	check_file_exists ~/.config/kitty/kitty.conf.dark

	ln -sf ~/.tmux.conf.dark ~/.tmux.conf
	ln -sf ~/.config/kitty/kitty.conf.dark ~/.config/kitty/kitty.conf
	sed -i 's/settings\["background"\] = "light"/settings\["background"\] = "dark"/' "$nvim_setting"

	kill_process $(pgrep kitty)
	set_neovim_background "dark"
	tmux source-file ~/.tmux.conf

else
	exit 1
fi
