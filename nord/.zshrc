# If you come from bash you might have to change your $PATH.
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

# Path to your oh-my-zsh installation.
export ZSH="/home/ayamir/.oh-my-zsh"
export EDITOR="nvim"
export HTTP_PROXY="http://127.0.0.1:8889"
export ALL_PROXY="http://127.0.0.1:8889"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
    extract
    vi-mode
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
