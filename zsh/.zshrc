if [[ -t 0 ]]; then
    stty stop undef
    stty start undef
fi

# 補完
autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
setopt auto_menu
zstyle ':completion:*:default' menu select=2
setopt list_packed
bindkey "[Z" reverse-menu-complete
setopt nolistbeep
setopt list_types
setopt list_rows_first
setopt magic_equal_subst
setopt no_flow_control

# 言語
export LANG=ja_JP.UTF-8
setopt print_eight_bit

# もしかして機能
setopt correct

# 色
autoload -Uz colors; colors

# プロンプト
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
setopt prompt_subst
zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" max-exports 1
zstyle ":vcs_info:git:*" check-for-changes true
zstyle ":vcs_info:git:*" formats     "[%b]%c%u%m"
zstyle ":vcs_info:git:*" unstagedstr "[-]"
zstyle ":vcs_info:git:*" stagedstr   "[+]"
zstyle ":vcs_info:git+set-message:*" hooks git-remote

function +vi-git-untracked() {
    if git status --porcelain 2>/dev/null | grep '^??' >/dev/null 2>&1; then
        hook_com[misc]+='[N]'
    fi
}

function +vi-git-remote() {
    local remote="$(git rev-parse --abbrev-ref @{u} 2>/dev/null)"
    if [[ -n "${remote}" ]]; then
        hook_com[misc]+=" → [${remote}]"
    fi
}

function _init_psvar() {
    psvar=()
}

function _update_vcs_info_msg() {
    vcs_info

    if [[ -z "${vcs_info_msg_0_}" ]]; then
        return
    fi

    if [[ "${vcs_info_msg_0_}" =~ '\[[N+-]\]' ]]; then
        psvar[1]=""
        psvar[2]="✘ ${vcs_info_msg_0_}"
    else
        psvar[1]="✔ ${vcs_info_msg_0_}"
        psvar[2]=""
    fi

    psvar[3]="$(git config user.name) <$(git config user.email)>"
}

add-zsh-hook precmd _init_psvar
add-zsh-hook precmd _update_vcs_info_msg

PROMPT="
%F{4}%n@%m:%~%f %F{green}%1v%f%F{red}%2v%f
%(?.%F{8}.%F{red})%%%f "
RPROMPT="%F{8}%3v%f"

export HISTFILE=$ZDOTDIR/.zhistory
export HISTSIZE=1000 # メモリに保存される履歴
export SAVEHIST=100000 # ファイルに保存される履歴
setopt share_history # 履歴を複数端末間で共有する
setopt hist_no_store # historyコマンド自体は保存しない
setopt hist_reduce_blanks # 履歴の空白はつめる

export LESSHISTFILE=-
export LESSCHARSET=utf-8

export FZF_DEFAULT_OPTS="--reverse --multi --exit-0 --cycle --inline-info --ansi --height 30%"

source $ZDOTDIR/plugin.zsh
source $ZDOTDIR/alias.zsh
