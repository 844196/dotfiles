# 補完
autoload -U compinit; compinit
setopt -U auto_cd
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
setopt pushd_ignore_dups

setopt auto_menu
zstyle ':completion:*:default' menu select=1
setopt list_packed

# 言語
export LANG=ja_JP.UTF-8
setopt print_eight_bit

# もしかして機能
setopt correct

# ひょうしき
PROMPT="%B%F{green}(๑•﹏•)%f%b %/%\ %(!.#.$) "

# もしかして
SPROMPT="%B%F{red}(๑•﹏•)%f%b < %rのことですかね...? [y, n, a, e]:"

# 右プロンプトにGitブランチを表示
RPROMPT=%F{239}$'`get-branch-name`'%f
setopt prompt_subst
function get-branch-name {
    echo `git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'`
}

# /usr/binより/usr/local/binを優先
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/dotfiles/shellscript:$PATH

# 重複パスを登録しない
typeset -U path cdpath fpath manpath

## sudo用のpathを設定
typeset -xT SUDO_PATH sudo_path
typeset -U sudo_path
sudo_path=({/usr/local,/usr,}/sbin(N-/))

# pathを設定
path=(~/bin(N-/) /usr/local/bin(N-/) ${path})

# リロード
alias reload="source ~/.zshrc"

# エイリアス
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

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

# weather.sh用環境変数
export LOCATION='Monbetsu'
export TMP=$HOME/.tmp

# .zshrc_localがあったらそれも読み込む
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
