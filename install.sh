#!/bin/bash

if ! which git >/dev/null 2>&1; then
  echo "${cmd} is not installed" >&2
  exit 1
fi

for cmd in zsh fzf; do
  which $cmd >/dev/null 2>&1 || echo "${cmd} is not installed" >&2
done

git clone https://github.com/844196/dotfiles ~/.dotfiles

my_ln() {
  if [ -f $2 ]; then
    echo "${2} is already exists. skipping..." >&2
    return
  fi
  ln -sfn $1 $2
}

mkdir -p ~/.config
my_ln ~/.dotfiles/git ~/.config/git

my_ln ~/.dotfiles/zsh ~/.zsh
my_ln ~/.dotfiles/zsh/.zshenv ~/.zshenv
