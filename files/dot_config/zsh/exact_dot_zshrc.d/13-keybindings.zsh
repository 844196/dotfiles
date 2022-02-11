autoload -Uz dot-widget-init && dot-widget-init

bindkey '^[[Z' reverse-menu-complete
bindkey '^M' dot-accept-line-and-expand-alias
bindkey ' ' dot-self-insert-and-expand-alias
bindkey '^[[1;2A' dot-pushd-up-and-reset-prompt
bindkey '^[[1;2B' dot-popd-and-reset-prompt
bindkey '^R' dot-put-history
bindkey '^X^B' dot-insert-git-branch
bindkey '^X^F' dot-insert-git-file
bindkey '^X^G' dot-cd-ghq-repository
bindkey '^X^M' dot-zoxide
