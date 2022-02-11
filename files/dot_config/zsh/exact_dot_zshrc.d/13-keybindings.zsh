autoload -Uz dot-widget-init && dot-widget-init

bindkey '^[[Z' reverse-menu-complete
bindkey '^M' dot-widget-accept-line-with-expand-alias
bindkey ' ' dot-widget-self-insert-with-expand-alias
bindkey '^[[1;2A' dot-widget-pushd-up-with-reset-prompt
bindkey '^[[1;2B' dot-widget-popd-with-reset-prompt
bindkey '^R' dot-widget-put-history
bindkey '^X^B' dot-widget-insert-git-branch
bindkey '^X^F' dot-widget-insert-git-file
bindkey '^X^G' dot-widget-cd-ghq-repository
