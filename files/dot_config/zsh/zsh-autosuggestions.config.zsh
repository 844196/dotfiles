export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bold"
export ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
  dot-expand-alias-and-accept-line

  # SEE: https://github.com/zsh-users/zsh-autosuggestions/issues/619
  history-beginning-search-backward-end
  history-beginning-search-forward-end

  $ZSH_AUTOSUGGEST_CLEAR_WIDGETS
)
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
