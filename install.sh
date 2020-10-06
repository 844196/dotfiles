#!/bin/bash

if ! which git >/dev/null 2>&1; then
  echo "${cmd} is not installed" >&2
  exit 1
fi

for cmd in zsh fzf; do
  which $cmd >/dev/null 2>&1 || echo "${cmd} is not installed" >&2
done

[ -e ~/.dotfiles ] || git clone https://github.com/844196/dotfiles ~/.dotfiles

cp -f ~/.dotfiles/git/ignore ~/.gitignore
cp -f ~/.dotfiles/git/config ~/.gitconfig
sudo cp -f ~/.dotfiles/git/git-credential-manager /usr/local/bin/git-credential-manager

ln -sfn ~/.dotfiles/zsh ~/.zsh
ln -sfn ~/.dotfiles/zsh/.zshenv ~/.zshenv
