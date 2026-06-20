# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH="$HOME/.fly/bin:$PATH"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
. "$HOME/.cargo/env"
alias python=python3
export PATH="$HOME/tools/ghidra:$PATH"
alias ghidra="~/tools/ghidra/ghidraRun"

# ==================================================================
# Git状態を表示する関数定義
# ==================================================================
function parse_git_branch(){
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# ==================================================================
# カスタムプロンプト（パステルカラー）
# 1行目: 時間 ホスト名@IPアドレス フルパス
# 2行目: (ｯ･ω･)ｯ gitブランチ
# ==================================================================

# --- パステルカラー定義 ---
COLOR_RESET='\[\033[00m\]'
COLOR_PURPLE='\[\033[38;5;183m\]'   # 薄紫（時間）
COLOR_PINK='\[\033[38;5;218m\]'     # ピンク（ホスト名@IP）
COLOR_BLUE='\[\033[38;5;117m\]'     # 水色（ディレクトリ）
COLOR_GREEN='\[\033[38;5;157m\]'    # 薄緑（絵文字・git）
COLOR_YELLOW='\[\033[38;5;228m\]'   # 薄黄（バッテリー）

# --- IP取得用の関数 ---
function get_ip(){
    hostname -I | awk '{print $1}'
}

# --- バッテリー取得用の関数 ---
function get_battery(){
    local capacity=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
    local status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
    if [ -z "$capacity" ]; then return; fi
    if [ "$status" = "Charging" ]; then
        echo "${capacity}%"
    else
        echo "${capacity}%"
    fi
}

# --- PS1 組み立て ---
PS1=""
PS1+="${COLOR_PURPLE}\t"            # 時間 (HH:MM:SS)
PS1+=" "
PS1+="${COLOR_PINK}\h@\$(get_ip)"   # ホスト名@IPアドレス
PS1+=" "
PS1+="${COLOR_BLUE}\w"              # フルパスディレクトリ
PS1+=" "
PS1+="${COLOR_YELLOW}\$(get_battery)"  # バッテリー残量
PS1+="${COLOR_RESET}"
PS1+="\n"                           # 改行
PS1+="${COLOR_GREEN}(ｯ･ω･)ｯ "      # 絵文字
PS1+="\$(parse_git_branch)"         # gitブランチ名
PS1+="${COLOR_RESET}"
PS1+="$ "                           # 入力プロンプト
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx



export PATH="$HOME/jadx/bin:$PATH"
export PATH="$PATH:/opt/mssql-tools18/bin"
alias ime-check="gsettings get org.gnome.desktop.input-sources sources"
. "/home/roze123/.deno/env"
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# ==================================================================
# このマシン固有のローカル設定（git管理外。あれば読み込む）
# ==================================================================
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
