export ZDOTDIR=~/.zsh

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
