`which fzf >/dev/null 2>&1` || return

export FZF_DEFAULT_OPTS="--reverse --multi --exit-0 --cycle --inline-info --ansi --height 50%"

if [[ -n "${commands[ag]:-}" ]]; then
    export FZF_DEFAULT_COMMAND="ag --skip-vcs-ignores --hidden --ignore-dir '.git/' -g ''"
else
    export FZF_DEFAULT_COMMAND="find . -type f -not -iwholename '*/.git/*' | sed 's;^./;;g' | sort"
fi

: 'コマンド履歴を<C-r>で表示' && {
    functions fzf-history() {
        BUFFER=$(fc -l -n 1 | fzf --tac --inline-info --height 50%)
        CURSOR=$#BUFFER
        zle reset-prompt
    }
    zle -N fzf-history
    bindkey '^R' fzf-history
}

: 'ghqで取ってきたリポジトリへcd' && {
    if `which ghq >/dev/null 2>&1`; then
        alias gp='cd $(ghq list --full-path | fzf)'
    fi
}

: 'コミット選択' && {
    alias -g C='`git graph -n 200 | fzf --reverse --ansi | sed -e "s/\([a-zA-Z0-9]\{1,\}\).*/\1/" -e "s/^[^a-zA-Z0-9]\{1,\}//g"`'
}

: 'ブランチ選択' && {
    alias -g B='`git branch | fzf --reverse --ansi --exact | sed -e "s/^[\* ]\{0,1\} //g"`'
}

: 'ブランチ切り替え' && {
    alias cb='git checkout B'
}

: 'rebase -i' && {
    alias rb='git rebase -i C'
}

: 'unstage file select' && {
    alias -g F='$(git status --porcelain | fzf --preview "echo {} | cut -c4- | xargs git diff --color=always HEAD" | cut -c4-)'
}
