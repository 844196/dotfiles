if [ -t 0 ]; then
  stty stop undef
  stty start undef
fi

export PATH="$PATH:$HOME/.local/bin"

export HISTCONTROL=ignoredups:erasedups

export LESSHISTFILE=-
export LESSCHARSET=utf-8

PS1='
\[\e[34m\]\u@\h:\w\[\e[m\]
`((${?:-0}==0))&&echo "\[\e[1;30m\]"||echo "\[\e[31m\]"`\$\[\e[m\] '

if [ `uname` = Darwin ]; then
  alias ls='ls -GFh'
else
  alias ls='ls -Fh --color'
fi

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias t='cd "$(mktemp -d)"'
alias st='git status'
alias ck='git checkout'
alias br='git branch -vv'
alias co='git commit'
alias di='git diff'
alias gg='git graph -n 15'

# starship
if which starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
