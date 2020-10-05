#!/bin/bash

if ! which git >/dev/null 2>&1; then
  echo "${cmd} is not installed" >&2
  exit 1
fi

for cmd in zsh fzf; do
  which $cmd >/dev/null 2>&1 || echo "${cmd} is not installed" >&2
done

[ -e ~/.dotfiles ] || git clone https://github.com/844196/dotfiles ~/.dotfiles

my_ln() {
  if [ -e $2 ]; then
    echo "${2} is already exists. skipping..." >&2
    return
  fi
  ln -sfn $1 $2
}

cp -f ~/.dotfiles/git/ignore ~/.gitignore
cp -f ~/.dotfiles/git/config ~/.gitconfig

my_ln ~/.dotfiles/zsh ~/.zsh
my_ln ~/.dotfiles/zsh/.zshenv ~/.zshenv
