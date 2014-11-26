functions _zstart() {
    dot="$(tput smso)  $(tput rmso)"
    clear
    echo "
     $dot  $dot    $dot      $dot  $dot      $dot              $dot                  $dot
   $dot$dot$dot$dot$dot  $dot    $dot    $dot          $dot$dot      $dot    $dot$dot$dot    $dot$dot  $dot
     $dot  $dot    $dot    $dot    $dot$dot    $dot  $dot  $dot    $dot        $dot  $dot$dot    $dot$dot
   $dot$dot$dot$dot$dot      $dot      $dot  $dot  $dot  $dot  $dot  $dot        $dot      $dot$dot  $dot  $dot
     $dot  $dot    $dot  $dot      $dot$dot    $dot  $dot  $dot  $dot      $dot$dot$dot  $dot$dot    $dot  $dot
    "
}
_zstart

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
bindkey "[Z" reverse-menu-complete

# 言語
export LANG=ja_JP.UTF-8
setopt print_eight_bit

# もしかして機能
setopt correct

# プロンプト文字、関数の評価
setopt prompt_subst
autoload -Uz add-zsh-hook

# 色
autoload -Uz colors; colors

# プロンプト
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' max-exports 3
zstyle ':vcs_info:git:*' stagedstr " "
zstyle ':vcs_info:git:*' unstagedstr " "
zstyle ':vcs_info:*' formats "%b" "%c%u"

_update_vcs_info() {
    psvar=()
    LANG=en_US.UTF-8 vcs_info

    if [[ -z ${vcs_info_msg_0_} ]]; then
        psvar[1]=""
        psvar[2]=""
    else
        if [[ -n "${vcs_info_msg_1_}" ]]; then
            psvar[1]=""
            psvar[2]=( "☂ ${vcs_info_msg_0_}" )
        else
            psvar[1]=( "☀ ${vcs_info_msg_0_}" )
            psvar[2]=""
        fi
    fi
}
add-zsh-hook precmd _update_vcs_info

PROMPT="
%B%F{34}%n@%m%f%b:%~ %F{34}%1v%f%F{red}%2v%f
%B%(?.%F{blue}.%F{red})%(!.#.⟩)%f%b "

if [ $ismac = '0' ]; then
    SPROMPT="%B%F{red}(๑•﹏•)%f%b < %rのこと言ってるんですかね...? [y, n, a, e]:"
else
    SPROMPT="%B%F{red}(X | _ | )%f%b < お前が%rと思うんならそうなんだろう. お前ん中ではな. [y, n, a, e]:"
fi

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

# リロード
alias reload="source ~/.zshrc"

# エイリアス
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias cls="clear"
alias quicklook="qlmanage -p"
alias l="qlmanage -p"
alias ls='ls -GFh'

if [ -e /Applications/MacVim.app ]; then
    alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
    alias gvim='/Applications/MacVim.app/Contents/MacOS/mvim'
fi

function pcolor() {
    for ((f = 0; f < 255; f++)); do
        printf "\e[38;5;%dm %3d#\e[m" $f $f
        if [[ $f%8 -eq 7 ]] then
            printf "\n"
        fi
    done
    echo
}

functions _his() {
    BUFFER=$(fc -l -n 1 | tail -r | peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle -R -c
}
if which peco >/dev/null 2>&1; then
    zle -N _his
    alias his='_his'
    bindkey '^R' _his
fi

# Git
_git() {
    if `git status >/dev/null 2>&1`; then
        command=${1}
        shift
        git ${command} "$@"
        return 0
    else
        echo "_git: Not a git repository" 1>&2
        return 1
    fi
}

_git_alias_B() {
    if `git status >/dev/null 2>&1`; then
        if `which peco >/dev/null 2>&1`; then
            alias -g B='`git branch | peco | head -n 1 | sed -e "s/^\*\s//g"`'
        else
            unalias \B >/dev/null 2>&1
        fi
    else
        unalias \B >/dev/null 2>&1
    fi
}
add-zsh-hook precmd _git_alias_B

alias st='_git status'
alias ck='git checkout'
alias br='_git branch'
alias co='_git commit'
alias mr='_git merge'
alias pu='_git push'

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
