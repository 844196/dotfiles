export ZDOTDIR=~/.zsh

# XDG Base Directory Specification
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

# my bin
path=($HOME/dotfiles/bin(N-/) $path)
path=($HOME/bin_local(N-/) $path)

# homebrew
path=(/usr/local/bin(N-/) $path)
fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)

# composer
path=($HOME/.composer/vendor/bin(N-/) $path)

# golang
export GOPATH=~/.go
path=($GOPATH/bin(N-/) $path)

# rbenv
path=($HOME/.rbenv/bin(N-/) $path)
which rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

typeset -U path fpath
