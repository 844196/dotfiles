HISTFILE=$XDG_STATE_HOME/zsh/history
HISTSIZE=1000
SAVEHIST=100000

setopt share_history
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

zshaddhistory() {
  local line=${1%%$'\n'}
  local cmd=${line%% *}

  [[ ${#line} -ge 5
    && $cmd != (cd|gp|pwd)
    && $cmd != (ls|exa)
    && $cmd != (less|bat)
    && $line != *--(help|version)
    && $line != (git status|git graph)
  ]]
}
