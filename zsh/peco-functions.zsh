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

: 'ブランチ切り替え' && {
    alias cb="git branch | peco | sed 's/^[\* ]\? //g' | xargs git checkout"
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
