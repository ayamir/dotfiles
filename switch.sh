#!/usr/bin/env bash

nvim_setting=~/.config/nvim/lua/user/settings.lua
vscode_setting=~/.config/Code/User/settings.json
mode_state_file=~/.mode_switch_state

check_file_exists() {
	if [ ! -f "$1" ]; then
		exit 1
	fi
}

check_macos() {
	local os_name=$(uname -s)
	if [ "$os_name" = "Darwin" ]; then
		return 0
	else
		return 1
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
	if check_macos; then
		servers=$(lsof -U | grep nvim | grep /var/folders | awk '{print $8}')
	fi
	for server in $servers; do
		nvim --server $server --remote-send ":set background=$background<CR>"
	done
}

switch_mode() {
	input=$1
	if [ "$input" == "light" ]; then
		check_file_exists ~/.tmux.conf.light
		check_file_exists ~/.config/kitty/kitty.conf.light
		ln -sf ~/.tmux.conf.light ~/.tmux.conf
		ln -sf ~/.config/kitty/kitty.conf.light ~/.config/kitty/kitty.conf
		perl -i -pe 's/settings\["background"\] = "dark"/settings\["background"\] = "light"/' "$nvim_setting"
		perl -i -pe 's/"workbench.colorTheme": "Default Dark Modern"/"workbench.colorTheme": "Default Light Modern"/' "$vscode_setting"
		kill_process $(pgrep kitty)
		kill_process $(pgrep nvim)
		set_neovim_background "light"
		tmux source-file ~/.tmux.conf
	elif [ "$input" == "dark" ]; then
		check_file_exists ~/.tmux.conf.dark
		check_file_exists ~/.config/kitty/kitty.conf.dark
		ln -sf ~/.tmux.conf.dark ~/.tmux.conf
		ln -sf ~/.config/kitty/kitty.conf.dark ~/.config/kitty/kitty.conf
		perl -i -pe 's/settings\["background"\] = "light"/settings\["background"\] = "dark"/' "$nvim_setting"
		perl -i -pe 's/"workbench.colorTheme": "Default Light Modern"/"workbench.colorTheme": "Default Dark Modern"/' "$vscode_setting"
		kill_process $(pgrep kitty)
		kill_process $(pgrep nvim)
		set_neovim_background "dark"
		tmux source-file ~/.tmux.conf
	else
		exit 1
	fi
}

get_current_mode() {
	if [ -f "$mode_state_file" ]; then
		cat "$mode_state_file"
	else
		echo "light"
	fi
}

set_current_mode() {
	echo "$1" >"$mode_state_file"
}

toggle_mode() {
	current_mode=$(get_current_mode)
	if [ "$current_mode" == "light" ]; then
		set_current_mode "dark"
		switch_mode "dark"
	else
		set_current_mode "light"
		switch_mode "light"
	fi
}

if [ $# -eq 0 ]; then
	toggle_mode
elif [ "$1" == "toggle" ]; then
	toggle_mode
elif [ "$1" == "light" ]; then
	set_current_mode "light"
	switch_mode "light"
elif [ "$1" == "dark" ]; then
	set_current_mode "dark"
	switch_mode "dark"
else
	echo "Usage: $0 {light|dark|toggle}"
	exit 1
fi
