# 補完
autoload -U compinit; compinit
setopt -U auto_cd
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

setopt auto_menu
zstyle ':completion:*:default' menu select=1
setopt list_packed

# 言語
export LANG=ja_JP.UTF-8
setopt print_eight_bit

# もしかして機能
setopt correct

# ひょうしき
#PROMPT="%B%F{green}(๑•﹏•)%f%b %# "
PROMPT="%B%F{green}(๑•﹏•)%f%b %/%\ $ "
SPROMPT="%B%F{red}(๑•﹏•)%f%b < もしかして %r ? [n, y, a, e]:"

# 右プロンプトにディレクトリを表示
#RPROMPT="[%~%\]"
#setopt transient_rprompt

# /usr/binより/usr/local/binを優先
export PATH=/usr/local/bin:$PATH

# リロード
alias reload="source ~/.zshrc"

# エイリアス
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias ls="ls -aF"
alias rmdir="rm -rf"
alias cls="clear"
alias quicklook="qlmanage -p"
alias l="qlmanage -p"

function pcolor() {
    for ((f = 0; f < 255; f++)); do
        printf "\e[38;5;%dm %3d#\e[m" $f $f
        if [[ $f%8 -eq 7 ]] then
            printf "\n"
        fi
    done
    echo
} 

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
