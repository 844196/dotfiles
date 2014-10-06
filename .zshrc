# 環境依存
if [ `uname` = 'Darwin' ]; then
    ismac='0'
else
    ismac='1'
fi

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

# プロンプト文字の評価
setopt prompt_subst

# 色
autoload -Uz colors; colors

# ひょうしき
PROMPT="%(?.%B%F{green}.%B%F{blue})%(?!(๑•﹏•)!(๑>﹏<%))%f%b %/%\ %(!.#.$) "

# もしかして
SPROMPT="%B%F{red}(๑•﹏•)%f%b < %rのことですかね...? [y, n, a, e]:"

# 右プロンプトにGitブランチを表示
RPROMPT=%F{239}$'`get-branch-name`'%f
setopt prompt_subst
function get-branch-name {
    echo `git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'`
}

# 履歴ファイルの保存先
export HISTFILE=$HOME/.zsh_history

# メモリに保存される履歴
export HISTSIZE=1000

# ファイルに保存される履歴
export SAVEHIST=100000

# 履歴を複数端末間で共有する
setopt share_history

# zshを同時に複数起動してる場合は、履歴を上書きせずに追加
setopt append_history

# 履歴を重複して保存しない
setopt hist_ignore_dups

# 直前のコマンドが履歴にある場合は上書きする
setopt hist_ignore_all_dups

# 履歴の開始と終了を記録
setopt EXTENDED_HISTORY

# historyコマンド自体は保存しない
setopt hist_no_store

# 履歴の空白はつめる
setopt hist_reduce_blanks

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

# tmux自動起動
if [ -z "${TMUX}" -a -z "${STY}" ]; then
    if type tmux >/dev/null 2>&1; then
        if tmux has-session && tmux list-sessions | grep -q '.*]$'; then
            tmux attach
        else
            tmux new-session
        fi
    fi
fi

# .zshrc_localがあったらそれも読み込む
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
