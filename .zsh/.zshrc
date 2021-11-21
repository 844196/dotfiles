autoload -Uz select-word-style; select-word-style default
autoload -Uz compinit; compinit
autoload -Uz colors; colors

zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z} r:|[-_.]=**' '+m:{A-Z}={a-z} r:|[-_.]=**'
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
bindkey "[Z" reverse-menu-complete
setopt auto_menu
setopt list_packed
setopt nolistbeep
setopt list_types
setopt list_rows_first
setopt magic_equal_subst

setopt auto_pushd
setopt pushd_ignore_dups

setopt no_flow_control
setopt print_eight_bit
setopt transient_rprompt
if [ "$TERM_PROGRAM" = "vscode" ]; then
  # see: https://superuser.com/questions/1391414/why-am-i-having-a-sign-between-the-lines-in-integrated-terminal-in-vs-code
  unsetopt PROMPT_SP
fi

export HISTFILE=$ZDOTDIR/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt share_history
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

accept-line-with-expand-alias() {
  zle _expand_alias
  zle accept-line
}
zle -N accept-line-with-expand-alias
bindkey -M emacs '^M' accept-line-with-expand-alias
bindkey '^J' accept-line-with-expand-alias

space-with-expand-alias() {
  zle _expand_alias
  zle self-insert
}
zle -N space-with-expand-alias
bindkey -M emacs ' ' space-with-expand-alias

cd-up() {
  pushd .. >/dev/null
  zle reset-prompt
}
zle -N cd-up
bindkey '^[[1;2A' cd-up

cd-undo() {
  popd >/dev/null 2>&1
  zle reset-prompt
}
zle -N cd-undo
bindkey '^[[1;2B' cd-undo

PROMPT="
%{$fg[blue]%}%n@%m:%~%{$reset_color%}
%{%(?.$fg_bold[black].$fg[red])%}%#%{$reset_color%} "

if [ `uname` = Darwin ]; then
  alias ls='ls -GFh'
else
  alias ls='ls -Fh --color'
fi

if [ -n "${commands[exa]}" ]; then
  alias ls="exa -gF --icons --git"
fi

if [ -n "${commands[fzf]}" ]; then
  fzf-histories() {
    BUFFER=$(fc -l -n 1 | fzf --tac)
    CURSOR=$#BUFFER
    zle reset-prompt
  }
  zle -N fzf-histories
  bindkey '^R' fzf-histories

  fzf-git-branches() {
    local selected="$(git branch --color=always -vvv --sort=-authordate | SHELL=${commands[zsh]} fzf --exact --preview-window down:70% --preview '
      () {
        local branch=$(echo $1 | grep -o -E "^[ *] \S+" | cut -c3-)
        git log -50 --oneline --no-decorate --color=always $branch
      } {}
    ' | grep -o -E '^[ *] \S+' | cut -c3- | tr '\n' ' ')"

    BUFFER="${BUFFER}${selected}"
    CURSOR=${#BUFFER}
    zle reset-prompt
  }
  zle -N fzf-git-branches
  bindkey '^x^b' fzf-git-branches

  fzf-git-changed-files() {
    local selected="$(git status --porcelain | SHELL=${commands[zsh]} fzf --height 90% --preview-window right:80% --preview '
      () {
        local marker="${1[0,2]}"
        local filename="${1[4,-1]}"

        if [ "$marker" = "??" ]; then
          local SHOWCMD=

          local bat=${commands[bat]:-${commands[batcat]}}
          if [ -n "$bat" ]; then
            SHOWCMD="batcat --color=always --line-range=:500 --style=plain"
          else
            SHOWCMD=cat
          fi

          eval $SHOWCMD "$filename"
        else
          git diff --color=always HEAD "$filename"
        fi
      } {}
    ' | cut -c4- | tr '\n' ' ')"

    BUFFER="${BUFFER}${selected}"
    CURSOR=${#BUFFER}
    zle reset-prompt
  }
  zle -N fzf-git-changed-files
  bindkey '^x^f' fzf-git-changed-files
fi

if [[ -n "${commands[fzf]}" && -n "${commands[ghq]}" ]]; then
  gp() {
    repo="`ghq list | fzf --no-multi`"
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
if [ -e $ZDOTDIR/plugins/zsh-autosuggestions ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bold"
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(accept-line-with-expand-alias)
  source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -e $ZDOTDIR/plugins/zsh-syntax-highlighting ]; then
  source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# starship
if [ -n "${commands[starship]}" ]; then
  eval "$(starship init zsh)"
fi