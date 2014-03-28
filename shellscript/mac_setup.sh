#!/bin/sh

#dotfiles
ln -s $HOME/dotfiles/.vimrc $HOME/.vimrc
ln -s $HOME/dotfiles/.vimshrc $HOME/.vimshrc
ln -s $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/dotfiles/.tmux.conf $HOME/.tmux.conf

#NeoBundle
mkdir -p $HOME/.vim/bundle
git clone git://github.com/Shougo/neobundle.vim $HOME/.vim/bundle/neobundle.vim

#Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew bundle

#Ricty
git clone https://github.com/yascentur/Ricty.git $HOME/Ricty
cd $HOME/Ricty
curl -L -o Inconsolata.otf "http://levien.com/type/myfonts/Inconsolata.otf"
curl -L -o migu-1m.zip "http://sourceforge.jp/frs/redir.php?m=jaist&f=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip"
unzip -j migu-1m.zip
sh ricty_generator.sh Inconsolata.otf migu-1m-regular.ttf migu-1m-bold.ttf
cp Ricty*.ttf $HOME/Library/Fonts/
cd $HOME
rm -rf $HOME/Ricty
