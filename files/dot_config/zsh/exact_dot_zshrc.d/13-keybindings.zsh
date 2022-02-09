autoload -Uz dot-widget-init && dot-widget-init

bindkey '^[[Z' reverse-menu-complete
bindkey '^M' dot-widget-accept-line-with-expand-alias
bindkey ' ' dot-widget-self-insert-with-expand-alias
bindkey '^[[1;2A' dot-widget-pushd-up-with-reset-prompt
bindkey '^[[1;2B' dot-widget-popd-with-reset-prompt

if [ -e $XDG_DATA_HOME/zsh/plugins/anyframe ]; then
  fpath=($XDG_DATA_HOME/zsh/plugins/anyframe(N-/) $fpath)
  autoload -Uz anyframe-init && anyframe-init

  bindkey '^r' anyframe-widget-put-history-alt
  bindkey '^x^b' anyframe-widget-insert-git-branch-alt
  bindkey '^x^f' anyframe-widget-insert-git-file
fi
