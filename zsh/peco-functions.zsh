`which peco >/dev/null 2>&1` || return

: 'コマンド履歴を<C-r>で表示' && {
    functions peco-history() {
        BUFFER=$(fc -l -n 1 | eval ${commands[tac]:-"tail -r"} | peco --query "$LBUFFER")
        CURSOR=$#BUFFER
        zle -R -c
    }
    zle -N peco-history
    bindkey '^R' peco-history
}

: 'ghqで取ってきたリポジトリへcd' && {
    if `which ghq >/dev/null 2>&1`; then
        alias gp='cd $(ghq list --full-path | peco)'
    fi
}

: 'Unite file_rec/git gitぽいやつ' && {
    functions peco-file_rec-git() {
        BUFFER="vim -O $(git ls-files | peco | tr '\n' ' ')"
        CURSOR=$#BUFFER
        zle -R -c
    }
    zle -N peco-file_rec-git
    bindkey '^\' peco-file_rec-git
}

: 'コミット選択' && {
    alias -g C='`git graph -n 200 | fzf --reverse --ansi | sed -e "s/\([a-zA-Z0-9]\{1,\}\).*/\1/" -e "s/^[^a-zA-Z0-9]\{1,\}//g"`'
}

: 'ブランチ選択' && {
    alias -g B='`git branch | fzf --reverse --ansi | sed -e "s/^[\* ]\? //g"`'
}

: 'ブランチ切り替え' && {
    alias cb='git checkout B'
}

: 'rebase -i' && {
    alias rb='git rebase -i C'
}
