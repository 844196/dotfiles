#!/bin/bash

if ! which git >/dev/null 2>&1; then
  echo "${cmd} is not installed" >&2
  exit 1
fi

for cmd in zsh fzf; do
  which $cmd >/dev/null 2>&1 || echo "${cmd} is not installed" >&2
done

git clone https://github.com/844196/dotfiles ~/.dotfiles

mkdir -p ~/.config
ln -sfn ~/.dotfiles/git ~/.config/git

ln -sfn ~/.dotfiles/zsh ~/.zsh
ln -sfn ~/.dotfiles/zsh/.zshenv ~/.zshenv
