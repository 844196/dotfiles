# my bin
path=($HOME/bin(N-/) $path)

# homebrew
path=(/usr/local/bin(N-/) $path)

# rbenv
eval "$(rbenv init -)"

typeset -U path PATH
