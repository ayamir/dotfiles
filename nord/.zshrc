# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# Path
export SYS_LOCAL_BIN="/usr/local/bin"
export LOCAL_BIN="$HOME/.local/bin"

export GOROOT="/usr/lib/go"
export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"

export HS_BIN="$HOME/.cabal/bin"

export NPM_BIN="$HOME/.npm-global/bin"

export KT_BIN="$HOME/.kotlin/bin"

export RS_BIN="$HOME/.cargo/bin"

export JAVA_HOME="/usr/lib/jvm/default"

export PATH=$SYS_LOCAL_BIN:$LOCAL_BIN:$GOBIN:$HS_BIN:$NPM_BIN:$RS_BIN:$JAVA_HOME:$PATH

export EDITOR="nvim"
export HTTP_PROXY="http://127.0.0.1:8889"

export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=true
export MCFLY_RESULTS=50
export MCFLY_INTERFACE_VIEW=BOTTOM
export MCFLY_RESULTS_SORT=LAST_RUN

#
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]/}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# completion
#

# Set a custom path for the completion dump file.
# If none is provided, the default ${ZDOTDIR:-${HOME}}/.zcompdump is used.
#zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    # Update static initialization script if it does not exist or it's outdated, before sourcing it
    source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
    bindkey ${terminfo[kcuu1]} history-substring-search-up
    bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}} End configuration added by Zim install

# Created by newuser for 5.8

alias v="nvim"
alias vi="nvim"
alias nv="nvim"
alias vim="nvim"
alias ne="neofetch"

alias vz="nvim ~/.zshrc"
alias sz="source ~/.zshrc"

alias ls="exa"
alias la="ls -a"
alias l="ls -alh"
alias l.="ls -d .* --color=auto"
alias ll="ls -l --color=auto"

alias jd="cd ~/Downloads"
alias jdc="cd ~/Downloads/Compressed"
alias jcl="cd ~/clone"

alias vp="nvim ~/.config/picom/picom.conf"
alias vc="cd ~/.dwm/; nvim ~/.dwm/config.def.h"
alias va="nvim ~/.dwm/autostart.sh"
alias vv="nvim ~/.config/nvim/init.vim"

alias py="python3"
alias pyins="pip3 install --user"
alias pyuins="pip3 uninstall"

alias ins="paru -S"
alias uins="yay -R"
alias up="paru"
alias c="paru -c"

alias stlsa="sudo systemctl start"
alias stlst="sudo systemctl stop"
alias stlsu="sudo systemctl status"
alias stlen="sudo systemctl enable"
alias stldis="sudo systemctl disable"
alias stlre="sudo systemctl restart"

alias og="git-open"
alias gc="git clone"
alias ga="git add"
alias gm="git commit -m"
alias gps="git push"

alias load="kill -USR1 $(pidof st)"
alias use="xrdb merge"

alias doom="~/.emacs.d/bin/doom"
alias clang++="clang++ -std=c++2a"

alias dc="docker-compose"
alias dps="docker ps"
alias dst="docker stop"
alias dru="docker run"
alias drm="docker rm"
alias dls="docker images ls"

alias x="extract"
alias ne="neofetch"
alias uzw="unzip -O cp936"
alias ra="ranger"
alias d2u="find . -type f -exec dos2unix {} +"
alias del="sh ~/.rm.sh"
alias tra="cd ~/.local/share/Trash/files && ls -a"
alias cl="rm -rf ~/.local/share/Trash/files/*"
alias po="sudo poweroff"
alias reb="sudo reboot"

source ~/.autojump/share/autojump/autojump.zsh
source /home/ayamir/.config/broot/launcher/bash/br
eval "$(mcfly init zsh)"
eval "$(zoxide init zsh)"
