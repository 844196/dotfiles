alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias t='cd "$(mktemp -d)"'
alias gp='anyframe-widget-cd-ghq-repository'

alias st='git status'
alias ck='git checkout'
alias br='git branch -vv'
alias co='git commit'
alias di='git diff'
alias gg='git graph -n 15'

alias c='chezmoi'
alias m='multipass'
alias d='docker'
alias curl='curl -fsSL'
alias grep='grep -E'

if [ -n "${commands[exa]}" ]; then
  alias ls='exa -gF --icons --git --color=always -la'
else
  if [ `uname` = Darwin ]; then
    alias ls='ls -GFh -la'
  else
    alias ls='ls -Fh --color -la'
  fi
fi
