export ZDOTDIR=~/.zsh

# XDG Base Directory Specification
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

# my bin
path=($HOME/bin(N-/) $path)

# homebrew
path=(/usr/local/bin(N-/) $path)
fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)

export ZPLUG_HOME=~/.zsh/zplug

typeset -U path fpath
