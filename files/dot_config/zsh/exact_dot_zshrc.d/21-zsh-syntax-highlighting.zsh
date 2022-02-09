if [ -e $XDG_DATA_HOME/zsh/plugins/zsh-syntax-highlighting ]; then
  typeset -A ZSH_HIGHLIGHT_STYLES

  # see: https://github.com/sheepla/dotfiles/blob/fd01d60b3b35fff10f5643ac7db9fca81ea32bb5/.zshrc#L282-L315
  ZSH_HIGHLIGHT_STYLES[command]='fg=white,bold'
  ZSH_HIGHLIGHT_STYLES[arg0]='fg=white,bold,underline'
  ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=white,bold,underline'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow,bold'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=green'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=green'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=cyan,underline'
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=cyan,bold,underline'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=blue,underline'
  ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=blue,bold,underline'
  ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=white,bold'
  ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=white,bold'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=white,bold'

  source $XDG_DATA_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
