if [ -n "${commands[direnv]}" ]; then
  eval "$(direnv hook zsh)"
fi
