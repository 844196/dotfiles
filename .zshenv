# my bin
path=($HOME/bin(N-/) $path)

# homebrew
path=(/usr/local/bin(N-/) $path)

# rbenv
eval "$(rbenv init -)"
path=($HOME/.rbenv/shims(N-/) $path)

typeset -U path PATH
