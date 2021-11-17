#!/bin/bash

if ! which git >/dev/null 2>&1; then
  echo 'Git is not installed' >&2
  exit 1
fi

[ -e ~/.dotfiles ] || git clone --depth 1 https://github.com/844196/dotfiles ~/.dotfiles

cp -f ~/.dotfiles/bash/.bashrc ~/.bashrc

cp -f ~/.dotfiles/zsh/zshenv ~/.zshenv
cp -f ~/.dotfiles/zsh/zshrc ~/.zshrc

cp -f ~/.dotfiles/git/config ~/.gitconfig
cp -f ~/.dotfiles/git/ignore ~/.gitignore

mkdir -p ~/bin
cp -f ~/.dotfiles/git/git-credential-manager ~/bin/git-credential-manager

[ -e ~/.fzf ] || git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
ln -sf ~/.fzf/bin/fzf ~/bin/fzf

mkdir -p ~/.zsh-plugins
[ -e ~/.zsh-plugins/zsh-syntax-highlighting ] || git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh-plugins/zsh-syntax-highlighting
[ -e ~/.zsh-plugins/zsh-autosuggestions ] || git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh-plugins/zsh-autosuggestions

sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir ~/bin --yes
