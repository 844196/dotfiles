if [[ ! -e $ZPLUG_HOME/init.zsh ]]; then
  exit 0
fi

source $ZPLUG_HOME/init.zsh

zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", on:"zsh-users/zsh-syntax-highlighting", defer:3

zplug load

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
