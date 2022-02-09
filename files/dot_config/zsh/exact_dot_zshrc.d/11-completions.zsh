setopt list_packed
setopt nolistbeep
setopt list_rows_first
setopt magic_equal_subst

zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z} r:|[-_.]=**' '+m:{A-Z}={a-z} r:|[-_.]=**'
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/compcache

autoload -Uz compinit && compinit -d $XDG_CACHE_HOME/zsh/compdump
