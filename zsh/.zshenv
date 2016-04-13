# my bin
path=($HOME/bin(N-/) $path)

# homebrew
path=(/usr/local/bin(N-/) $path)
fpath=(/usr/local/share/zsh/site-functions(N-/) $fpath)

# rbenv
which rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

typeset -U path fpath
