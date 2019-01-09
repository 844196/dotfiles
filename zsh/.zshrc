stty stop undef
stty start undef

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
TERM='screen-256color'

# プロンプト
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
setopt prompt_subst
zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" max-exports 1
zstyle ":vcs_info:git:*" check-for-changes true
zstyle ":vcs_info:git:*" formats     "[%b]%c%u %m"
zstyle ":vcs_info:git:*" unstagedstr "[-]"
zstyle ":vcs_info:git:*" stagedstr   "[+]"
zstyle ":vcs_info:git+set-message:*" hooks git-untracked git-remote

function +vi-git-untracked() {
    if git status --porcelain 2>/dev/null | grep '^??' >/dev/null 2>&1; then
        hook_com[unstaged]+='[N]'
    fi
}

function +vi-git-remote() {
    local remote="$(git rev-parse --abbrev-ref @{u} 2>/dev/null)"
    if [[ -n "${remote}" ]]; then
        hook_com[misc]+="→  [${remote}]"
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

case `uname` in
    'Darwin')
        SPROMPT="%B%F{red}(๑•﹏•)%f%b < %rのこと言ってるんですかね...? [y, n, a, e]:"
        ;;
    *)
        SPROMPT="%B%F{red}(X | _ | )%f%b < お前が%rと思うんならそうなんだろう. お前ん中ではな. [y, n, a, e]:"
        ;;
esac

# 履歴ファイルの保存先
export HISTFILE=$ZDOTDIR/.zhistory

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

# lessのエンコード
export LESSCHARSET=utf-8

# リロード
alias reload="source $ZDOTDIR/.zshrc"

# エイリアス
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

case `uname` in
    'Darwin')
        alias ls='ls -GFh'
        ;;
    *)
        alias ls='ls -Fh --color'
        ;;
esac

alias t='cd "$(mktemp -d)"'

# Git
alias st='git status'
alias ck='git checkout'
alias br='git branch -vv'
alias co='git commit'
alias di='git diff'
alias gg='git graph -n 15'

export ZPLUG_HOME=~/.zsh/zplug
if [[ -e $ZPLUG_HOME/init.zsh ]]; then
    source $ZPLUG_HOME/init.zsh

    zplug "zplug/zplug", hook-build:'zplug --self-manage'
    zplug "zsh-users/zsh-syntax-highlighting", if:"[[ ${ZSH_EVAL_CONTEXT} == 'file' ]]", defer:2
    zplug "zsh-users/zsh-autosuggestions", on:"zsh-users/zsh-syntax-highlighting", defer:3
    zplug "~/.zsh/site-functions", from:local

    zplug load
fi

if [[ -e ~/.local/zshrc ]]; then
    source ~/.local/zshrc
fi

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
