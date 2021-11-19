autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
setopt auto_menu
zstyle ':completion:*:default' menu select=2
setopt list_packed
bindkey "[Z" reverse-menu-complete
setopt nolistbeep
setopt list_types
setopt list_rows_first
setopt magic_equal_subst
setopt no_flow_control

setopt print_eight_bit

autoload -Uz colors; colors

export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt share_history
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

# for vscode
# see: https://superuser.com/questions/1391414/why-am-i-having-a-sign-between-the-lines-in-integrated-terminal-in-vs-code
unsetopt PROMPT_SP

# for wsl
# see: https://github.com/microsoft/WSL/issues/5065#issuecomment-835469034
precmd() {
  if [ ! -e "/run/WSL" ]; then
    return
  fi

  if [[ -z "$WSL_INTEROP" || -e "$WSL_INTEROP" ]]; then
    return
  fi

  local pid
  for pid in `pstree --numeric-sort --show-pids --show-parents $$ | grep -o -E '[0-9]+'`; do
    if [ -e "/run/WSL/${pid}_interop" ]; then
      export WSL_INTEROP="/run/WSL/${pid}_interop"
      return
    fi
  done
}

PROMPT="
%{$fg[blue]%}%n@%m:%~%{$reset_color%}
%{%(?.$fg_bold[black].$fg[red])%}%#%{$reset_color%} "

if [ `uname` = Darwin ]; then
  alias ls='ls -GFh'
else
  alias ls='ls -Fh --color'
fi

if [ -n "${commands[fzf]}" ]; then
  # see: https://github.com/junegunn/fzf/wiki/Color-schemes#ayu-mirage
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#cbccc6,bg:#1f2430,hl:#707a8c
    --color=fg+:#707a8c,bg+:#191e2a,hl+:#ffcc66
    --color=info:#73d0ff,prompt:#707a8c,pointer:#cbccc6
    --color=marker:#73d0ff,spinner:#73d0ff,header:#d4bfff
  '

  _fzf_history() {
    BUFFER=$(fc -l -n 1 | fzf --tac)
    CURSOR=$#BUFFER
    zle reset-prompt
  }
  zle -N _fzf_history
  bindkey '^R' _fzf_history

  alias -g B='`git branch | fzf --reverse --exact | sed -e "s/^[\* ]\{0,1\} //g"`'
  alias -g F='$(git status --porcelain | fzf --preview "echo {} | cut -c4- | xargs git diff --color=always HEAD" | cut -c4-)'
  alias -g C='`git graph -n 200 | fzf --reverse | sed -e "s/\([a-zA-Z0-9]\{1,\}\).*/\1/" -e "s/^[^a-zA-Z0-9]\{1,\}//g"`'
fi

if [[ -n "${commands[fzf]}" && -n "${commands[ghq]}" ]]; then
  gp() {
    repo="`ghq list | fzf`"
    if [ -z "$repo" ]; then
      return 1
    fi
    cd "`ghq list --full-path --exact $repo`"
  }
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

# plugins
if [ -e ~/.zsh-plugins/zsh-autosuggestions ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bold"
  source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -e ~/.zsh-plugins/zsh-syntax-highlighting ]; then
  source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# starship
if [ -n "${commands[starship]}" ]; then
  eval "$(starship init zsh)"
fi
