if [ -e $XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bold"
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(expand-alias-and-accept-line)

  source $XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
