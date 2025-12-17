#!/usr/bin/env bash

set -euo pipefail

check_macos() {
	local os_name
	os_name=$(uname -s)
	if [ "$os_name" = "Darwin" ]; then
		return 0
	else
		return 1
	fi
}

kill_process() {
	local pid=${1:-}
	if [ -n "$pid" ]; then
		kill -SIGUSR1 "$pid"
	fi
}

safe_perl() {
	local pattern=$1
	local file=$2

	if [ -f "$file" ]; then
		perl -i -pe "$pattern" "$file"
	fi
}

nvim_setting=~/.config/nvim/lua/user/settings.lua
chadrc=~/.config/nvim/lua/chadrc.lua
vscode_setting=~/.config/Code/User/settings.json
ghostty_setting=~/.config/ghostty/config
trae_setting=""
kitty_setting=~/.config/kitty/kitty.conf
tmux_setting=~/.tmux.conf
mode_state_file=~/.mode_switch_state

if check_macos; then
	vscode_setting=~/Library/'Application Support'/Code/User/settings.json
	ghostty_setting=~/Library/'Application Support'/com.mitchellh.ghostty/config
	trae_setting=~/Library/'Application Support'/'Trae CN'/User/settings.json
fi

set_neovim_background() {
	local background=$1
	local servers

	if check_macos; then
		servers=$(lsof -U 2>/dev/null | awk '/nvim/ && /\/var\/folders/ && !/fzf/ {print $8}')
	else
		servers=$(lsof -U 2>/dev/null | awk '/nvim/ && /\/run\/user/ && !/fzf/ {print $9}')
	fi

	if [ -f "$chadrc" ]; then
		if [ -n "$servers" ]; then
			for server in $servers; do
				nvim --server "$server" --remote-send ":lua require('base46').toggle_theme()<CR>"
			done
		else
			if [ "$background" = "dark" ]; then
				safe_perl 's/theme = "penumbra_light"/theme = "everforest"/' "$chadrc"
			else
				safe_perl 's/theme = "everforest"/theme = "penumbra_light"/' "$chadrc"
			fi
		fi
	else
		if [ "$background" = "dark" ]; then
			safe_perl 's/settings\["background"\] = "light"/settings\["background"\] = "dark"/' "$nvim_setting"
		else
			safe_perl 's/settings\["background"\] = "dark"/settings\["background"\] = "light"/' "$nvim_setting"
		fi

		if [ -n "$servers" ]; then
			for server in $servers; do
				nvim --server "$server" --remote-send ":set background=$background<CR>"
			done
		fi
	fi
}

switch_mode() {
	local input=$1

	case "$input" in
	light)
		# safe_perl 's/mocha/latte/' "$kitty_setting"
		# safe_perl 's/Mocha/Latte/' "$ghostty_setting"
		# osascript ~/clone/dotfiles/macOS/ghostty-reload-config.scpt
		# kill_process "$(pgrep kitty)"
		safe_perl 's/everforest/penu/' "$tmux_setting"
		[ -n "$trae_setting" ] && safe_perl 's/"workbench.colorTheme": "Dark"/"workbench.colorTheme": "Light"/' "$trae_setting"
		safe_perl 's/"workbench.colorTheme": "Default Dark Modern"/"workbench.colorTheme": "Default Light Modern"/' "$vscode_setting"
		set_neovim_background "light"
		~/.local/bin/iterm-theme penumbra_light
		tmux source-file "$tmux_setting"
		;;
	dark)
		# safe_perl 's/latte/mocha/' "$kitty_setting"
		# safe_perl 's/Latte/Mocha/' "$ghostty_setting"
		# osascript ~/clone/dotfiles/macOS/ghostty-reload-config.scpt
		# kill_process "$(pgrep kitty)"
		safe_perl 's/penu/everforest/' "$tmux_setting"
		[ -n "$trae_setting" ] && safe_perl 's/"workbench.colorTheme": "Light"/"workbench.colorTheme": "Dark"/' "$trae_setting"
		safe_perl 's/"workbench.colorTheme": "Default Light Modern"/"workbench.colorTheme": "Default Dark Modern"/' "$vscode_setting"
		set_neovim_background "dark"
		~/.local/bin/iterm-theme everforest_dark_low
		tmux source-file "$tmux_setting"
		;;
	*)
		echo "Invalid mode: $input" >&2
		return 1
		;;
	esac
}

get_current_mode() {
	if [ -f "$mode_state_file" ]; then
		cat "$mode_state_file"
	else
		echo "light"
	fi
}

set_current_mode() {
	printf '%s
' "$1" >"$mode_state_file"
}

toggle_mode() {
	local current_mode
	current_mode=$(get_current_mode)
	if [ "$current_mode" = "light" ]; then
		set_current_mode "dark"
		switch_mode "dark"
	else
		set_current_mode "light"
		switch_mode "light"
	fi
}

main() {
	local mode=${1:-toggle}

	case "$mode" in
	toggle)
		toggle_mode
		;;
	light | dark)
		set_current_mode "$mode"
		switch_mode "$mode"
		;;
	*)
		echo "Usage: $0 {light|dark|toggle}" >&2
		exit 1
		;;
	esac
}

main "$@"
