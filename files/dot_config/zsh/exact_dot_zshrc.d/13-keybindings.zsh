autoload -Uz dot-widget-init && dot-widget-init

bindkey '^[[Z' reverse-menu-complete
bindkey '^M' dot-accept-line-and-expand-alias
bindkey ' ' dot-self-insert-and-expand-alias
bindkey '^R' dot-put-history
bindkey '^X^B' dot-insert-git-branch
bindkey '^X^F' dot-insert-git-file
bindkey '^X^G' dot-cd-ghq
bindkey '^X^J' dot-cd-zoxide
