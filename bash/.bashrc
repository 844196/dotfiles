if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi

export LESSHISTFILE=-
export LESSCHARSET=utf-8

PS1='
\[\e[34m\]\u@\h:\w\[\e[m\]
`((${?:-0}==0))&&echo "\[\e[1;30m\]"||echo "\[\e[31m\]"`\$\[\e[m\] '

if type fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--reverse --multi --exit-0 --cycle --inline-info --ansi --height 30%"

  __fzf_search_history() {
    selected=$(fc -l 1 | sed 's/^\s*[0-9]*\s*//g' | awk '!a[$0]++' | fzf --tac)
    READLINE_LINE=$selected
    READLINE_POINT=${#selected}
  }
  bind -x '"\C-r": __fzf_search_history'
fi

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

if [[ `uname` = Darwin ]]; then
  alias ls='ls -GFh'
else
  alias ls='ls -Fh --color'
fi

alias t='cd "$(mktemp -d)"'

alias st='git status'
alias ck='git checkout'
alias br='git branch -vv'
alias co='git commit'
alias di='git diff'
alias gg='git graph -n 15'
alias gp='cd $(ghq list --full-path | fzf)'
