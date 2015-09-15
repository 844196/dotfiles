() {
    d="$(tput smso)  $(tput rmso)"
    clear
    echo "
     $d  $d    $d      $d  $d      $d              $d                  $d
   $d$d$d$d$d  $d    $d    $d          $d$d      $d    $d$d$d    $d$d  $d
     $d  $d    $d    $d    $d$d    $d  $d  $d    $d        $d  $d$d    $d$d
   $d$d$d$d$d      $d      $d  $d  $d  $d  $d  $d        $d      $d$d  $d  $d
     $d  $d    $d  $d      $d$d    $d  $d  $d  $d      $d$d$d  $d$d    $d  $d
    "
}

# 環境依存
if [ `uname` = 'Darwin' ]; then
    ismac='0'
else
    ismac='1'
fi

# 補完
fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)
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
TERM='xterm-256color'

# プロンプト
autoload -Uz vcs_info
zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" max-exports 2
zstyle ":vcs_info:git:*" check-for-changes true
zstyle ":vcs_info:git:*" formats     "[⭠%b]%c%u" "%m"
zstyle ":vcs_info:git:*" unstagedstr "[-]"
zstyle ":vcs_info:git:*" stagedstr   "[+]"
zstyle ":vcs_info:git+set-message:*" hooks git-untracked git-remote

function +vi-git-untracked() {
    [[ $1 = 0 ]] || return 0

    git status --porcelain 2>/dev/null | grep '^??' >/dev/null 2>&1 && hook_com[unstaged]+='[N]' || :
}

function +vi-git-remote() {
    [[ $1 = 1 ]] || return 0

    local remote_branch="$(git rev-parse --abbrev-ref @{u} 2>/dev/null)"
    [[ -n "${remote_branch}" ]] && hook_com[misc]+=" → [⭠${remote_branch}]" || :
}

function _init_psvar() { psvar=(); }

function _update_vcs_info_msg() {
    vcs_info; local msg="${vcs_info_msg_0_}${vcs_info_msg_1_}"

    if [[ -n "${msg}" ]]; then
        if echo ${vcs_info_msg_0_} | grep '\[[N+-]\]' >/dev/null 2>&1; then
            psvar[1]=""
            psvar[2]="✘ ${vcs_info_msg_0_}${vcs_info_msg_1_}"
        else
            psvar[1]="✔ ${vcs_info_msg_0_}${vcs_info_msg_1_}"
            psvar[2]=""
        fi
    fi
}

function _update_pwd_pretty() {
    if pwd | grep -e "${HOME}" >/dev/null 2>&1; then
        psvar[3]="`pwd | sed -e "s;${HOME};~;" -e "s;/; ⮁ ;g"`"
    else
        psvar[3]="`pwd | sed -e "s;/; ⮁ ;g" -e "s;^;/;"`"
    fi
}

add-zsh-hook precmd _init_psvar
add-zsh-hook precmd _update_vcs_info_msg
add-zsh-hook precmd _update_pwd_pretty

PROMPT="
%K{blue} %F{white}%n@%m %F{blue}%K{10}⮀%f %F{14}%3v %k%F{10}⮀%f %F{green}%1v%f%F{red}%2v%f
%(?.%F{blue}.%F{red})%(!.#.❯)%f "

if [ $ismac = '0' ]; then
    SPROMPT="%B%F{red}(๑•﹏•)%f%b < %rのこと言ってるんですかね...? [y, n, a, e]:"
else
    SPROMPT="%B%F{red}(X | _ | )%f%b < お前が%rと思うんならそうなんだろう. お前ん中ではな. [y, n, a, e]:"
fi

# 履歴ファイルの保存先
export HISTFILE=$ZDOTDIR/.zsh_history

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

# .lesshstを作成しない
export LESSHISTFILE=-

# リロード
alias reload="source $ZDOTDIR/.zshrc"

# エイリアス
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias cls="clear"
alias -g l="qlmanage -p ${@} >/dev/null 2>&1"
alias ls='ls -GFh'

if [ -e /Applications/MacVim.app ]; then
    export EDITOR='/Applications/MacVim.app/Contents/MacOS/Vim'
    alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
    alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
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
    which tac >/dev/null 2>&1 && tac='tac' || tac='tail -r'
    BUFFER=$(fc -l -n 1 | $tac | peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle -R -c
}
if which peco >/dev/null 2>&1; then
    zle -N _his
    alias his='_his'
    bindkey '^R' _his
fi

# Git
_git_alias() {
    if `git status >/dev/null 2>&1`; then
        command=${1}
        shift
        git ${command} "$@"
        if [ "${command}" = 'status' ]; then :; else echo ''; git status; fi
        return 0
    else
        echo "_git_alias: Not a git repository" 1>&2
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

_git_alias_C() {
    if `git status >/dev/null 2>&1`; then
        if `which peco >/dev/null 2>&1`; then
            alias -g C='`git log --oneline | peco | cut -d" " -f1`'
        else
            unalias \C >/dev/null 2>&1
        fi
    else
        unalias \C >/dev/null 2>&1
    fi
}
add-zsh-hook precmd _git_alias_C

alias st='_git_alias status'
alias ck='_git_alias checkout'
alias br='_git_alias branch'
alias co='_git_alias commit -v'
alias mr='_git_alias merge'
alias pu='_git_alias push'
alias di='_git_alias diff'
alias rb='_git_alias rebase'
alias gg='_git_alias graph | head'
alias lg='_git_alias logg'

# .zshrc_localがあったらそれも読み込む
if [ -f $ZDOTDIR/.zshrc_local ]; then
    source $ZDOTDIR/.zshrc_local
fi

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
