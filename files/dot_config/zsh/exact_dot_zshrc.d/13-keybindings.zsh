bindkey '^[[Z' reverse-menu-complete

expand-alias-and-accept-line() {
  zle _expand_alias
  zle accept-line
}
zle -N expand-alias-and-accept-line
bindkey '^M' expand-alias-and-accept-line

expand-alias-and-self-insert() {
  zle _expand_alias
  zle self-insert
}
zle -N expand-alias-and-self-insert
bindkey ' ' expand-alias-and-self-insert

bindkey '^R' dot-put-history
bindkey '^X^B' dot-insert-git-branch
bindkey '^X^F' dot-insert-git-file
bindkey '^X^G' dot-cd-ghq
bindkey '^X^J' dot-cd-zoxide
