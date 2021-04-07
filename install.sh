#!/bin/bash

if ! which git >/dev/null 2>&1; then
  echo 'Git is not installed' >&2
  exit 1
fi

[ -e ~/.dotfiles ] || git clone https://github.com/844196/dotfiles ~/.dotfiles

cp -f ~/.dotfiles/bash/.bashrc ~/.bashrc

cp -f ~/.dotfiles/git/ignore ~/.gitignore
cp -f ~/.dotfiles/git/config ~/.gitconfig

mkdir -p ~/bin
cp -f ~/.dotfiles/git/git-credential-manager ~/bin/git-credential-manager
