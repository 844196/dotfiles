#!/bin/bash

if ! which git >/dev/null 2>&1; then
  echo 'Git is not installed' >&2
  exit 1
fi

[ -e ~/.dotfiles ] || git clone --depth 1 https://github.com/844196/dotfiles ~/.dotfiles

cp -f ~/.dotfiles/.exports ~/.exports

cp -f ~/.dotfiles/.bashrc ~/.bashrc
cp -f ~/.dotfiles/.inputrc ~/.inputrc

cp -f ~/.dotfiles/.zshenv ~/.zshenv
cp -f ~/.dotfiles/.zshrc ~/.zshrc

cp -f ~/.dotfiles/.gitconfig ~/.gitconfig
cp -f ~/.dotfiles/.gitignore ~/.gitignore

cp -f ~/.dotfiles/.vimrc ~/.vimrc

mkdir -p ~/.local/bin
cp -f ~/.dotfiles/.local/bin/git-credential-manager ~/.local/bin/git-credential-manager

[ -e ~/.fzf ] || git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
ln -sf ~/.fzf/bin/fzf ~/.local/bin/fzf

mkdir -p ~/.zsh-plugins
[ -e ~/.zsh-plugins/zsh-syntax-highlighting ] || git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh-plugins/zsh-syntax-highlighting
[ -e ~/.zsh-plugins/zsh-autosuggestions ] || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh-plugins/zsh-autosuggestions

[ -e ~/.local/bin/starship ] || sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir ~/.local/bin --yes
mkdir -p ~/.config
cp -f ~/.dotfiles/starship.toml ~/.config/starship.toml
