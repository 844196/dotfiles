#!/bin/bash

git clone https://github.com/844196/dotfiles ~/.dotfiles

ln -sfn ~/.dotfiles/zsh ~/.zsh
ln -sfn ~/.dotfiles/zsh/.zshenv ~/.zshenv

mkdir -p ~/.config
ln -sfn ~/.dotfiles/git ~/.config/git
