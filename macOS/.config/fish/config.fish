set -gx NB_BIN /opt/nanobrew/prefix/bin
set -gx BREW_BIN /opt/homebrew/bin
set -gx LOCAL_BIN /Users/bytedance/.local/bin
set -gx CARGO_BIN /Users/bytedance/.cargo/bin
set -gx GOROOT /usr/local/go
set -gx GOPATH /Users/bytedance/go
set -gx GHCBIN $HOME/.ghcup/bin
set -gx MISE_PATH $HOME/.local/share/mise/shims
set -gx PATH $MISE_PATH  $LOCAL_BIN $CARGO_BIN $BREW_BIN $NB_BIN $GOROOT/bin $GOPATH/bin $GHCBIN $PATH
set -gx RUSTUP_DIST_SERVER "https://rsproxy.cn"
set -gx RUSTUP_UPDATE_ROOT "https://rsproxy.cn/rustup"

set -gx GIT_TERMINAL_PROMPT 1
set -gx HOMEBREW_NO_ANALYTICS 1

set -gx RUST_LOG debug
# set -gx RUST_BACKTRACE 1

if status is-interactive
   and not set -q TMUX
   and not test "$TERM_PROGRAM" = "vscode"
   and not test "$TERMINAL_EMULATOR" = "JetBrains-JediTerm"
   and not test "$VSCODE_INJECTION" = "1" # 检查 VS Code 特有变量
   and not test "$VSCODE_PID" != "" # 另一个 VS Code 特有变量
   and not test "$VSCODE_IPC_HOOK" != "" # VS Code IPC Hook 变量
    exec tmux -u new -A -D -t f4h
end

fish_vi_key_bindings
set -g fish_greeting
set -gx EDITOR nvim
set -gx LANG en_US.UTF-8

if status --is-interactive
	abbr --add --global .. "cd ./.."
	abbr --add --global ... "cd ./../.."
	abbr --add --global .... "cd ./../../.."

	abbr --add --global vf "nvim ~/.config/fish/config.fish"
	abbr --add --global sf "source ~/.config/fish/config.fish"

	abbr --add --global ls "eza"
	abbr --add --global l "eza -l --color=auto"
	abbr --add --global la "eza -alh --color=auto"
	abbr --add --global tree "eza -T"

	abbr --add --global py python3
	abbr --add --global pyins "pip3 install --user"
	abbr --add --global pyuins "pip3 uninstall"

	abbr --add --global ins "brew install"
	abbr --add --global uins "brew uninstall"

	abbr --add --global og "git-open"
	abbr --add --global lg "lazygit"
	abbr --add --global gc "git clone"
	abbr --add --global ga "git add"
	abbr --add --global gr "git restore ."
	abbr --add --global gm "git commit -m"
	abbr --add --global gps "git push"
	abbr --add --global gpl "git pull"

	abbr --add --global nv "nvim"
	abbr --add --global x "extract"
	abbr --add --global ne "neofetch"
	abbr --add --global ra "yazi"
	abbr --add --global :q "exit"

	abbr --add --global hugo "hugo --enableGitInfo"
	abbr --add --global pb "hugo && hugo-algolia -s"
	abbr --add --global md "devour typora"
	abbr --add --global jn "jupyter notebook"
	abbr --add --global coco "export LANG='zh_CN.UTF-8' && coco"
end

# mise activate fish | source
# zoxide init fish | source
# direnv hook fish | source
# source "$HOME/.cargo/env.fish"
# [ -f "$HOME/.bytebm/config/fish.sh" ]; and source "$HOME/.bytebm/config/fish.sh"
