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

# 色
autoload -Uz colors; colors
TERM='xterm-256color'

# プロンプト
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
setopt prompt_subst
zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" max-exports 2
zstyle ":vcs_info:git:*" check-for-changes true
zstyle ":vcs_info:git:*" formats     "[%b]%c%u" "%m"
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
    [[ -n "${remote_branch}" ]] && hook_com[misc]+=" →  [${remote_branch}]" || :
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
    local pwd="`pwd`"
    if [[ $pwd =~ $HOME ]]; then
        psvar[3]="${${pwd/$HOME/ }//\// ⮁ }"
    else
        psvar[3]="/${pwd//\// ⮁ }"
    fi
}

add-zsh-hook precmd _init_psvar
add-zsh-hook precmd _update_vcs_info_msg
# add-zsh-hook precmd _update_pwd_pretty

PROMPT="
%F{6}%n@%m:%f %F{yellow}%~%f %F{green}%1v%f%F{red}%2v%f
%(?.%F{blue}.%F{red})$%f "

case `uname` in
    'Darwin')
        SPROMPT="%B%F{red}(๑•﹏•)%f%b < %rのこと言ってるんですかね...? [y, n, a, e]:"
        ;;
    *)
        SPROMPT="%B%F{red}(X | _ | )%f%b < お前が%rと思うんならそうなんだろう. お前ん中ではな. [y, n, a, e]:"
        ;;
esac

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

# 古いコマンドと同じやつは保存しない
setopt hist_save_no_dups

# .lesshstを作成しない
export LESSHISTFILE=-

# リロード
alias reload="source $HOME/.zshrc"

# エイリアス
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

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
    BUFFER=$(fc -l -n 1 | eval ${commands[tac]:-"tail -r"} | peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle -R -c
}
if which peco >/dev/null 2>&1; then
    zle -N _his
    alias his='_his'
    bindkey '^R' _his
fi

# Git
alias st='git status'
alias ck='git checkout'
alias br='git branch'
alias co='git commit -v'
alias di='git diff'
alias gg='git graph | head'

# source
source_target=(
    /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    $HOME/.zshrc_local
)

for target in ${source_target[*]}; { [[ -f "$target" ]] && source "$target"; }

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
