autoload -Uz dot-widget-init && dot-widget-init

bindkey '^[[Z' reverse-menu-complete
bindkey '^M' .accept-line-and-expand-alias
bindkey ' ' .self-insert-and-expand-alias
bindkey '^[[1;2A' .pushd-up-and-reset-prompt
bindkey '^[[1;2B' .popd-and-reset-prompt
bindkey '^R' .put-history
bindkey '^X^B' .insert-git-branch
bindkey '^X^F' .insert-git-file
bindkey '^X^G' .cd-ghq-repository
