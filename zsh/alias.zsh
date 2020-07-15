alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

case `uname` in
  'Darwin')
    alias ls='ls -GFh'
    ;;
  *)
    alias ls='ls -Fh --color'
    ;;
esac

alias t='cd "$(mktemp -d)"'

alias st='git status'
alias ck='git checkout'
alias br='git branch -vv'
alias co='git commit'
alias di='git diff'
alias gg='git graph -n 15'
alias gp='cd $(ghq list --full-path | fzf)'

functions _fzf_history() {
  BUFFER=$(fc -l -n 1 | fzf --tac)
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N _fzf_history
bindkey '^R' _fzf_history

alias -g B='`git branch | fzf --reverse --exact | sed -e "s/^[\* ]\{0,1\} //g"`'
alias -g F='$(git status --porcelain | fzf --preview "echo {} | cut -c4- | xargs git diff --color=always HEAD" | cut -c4-)'
alias -g C='`git graph -n 200 | fzf --reverse | sed -e "s/\([a-zA-Z0-9]\{1,\}\).*/\1/" -e "s/^[^a-zA-Z0-9]\{1,\}//g"`'
alias cb='git checkout B'
