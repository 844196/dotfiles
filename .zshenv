# my bin
path=($HOME/bin(N-/) $path)

# homebrew
path=(/usr/local/bin(N-/) $path)
fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)

# rbenv
eval "$(rbenv init -)"

typeset -U path fpath
