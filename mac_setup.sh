#!/bin/sh

#dotfiles
ln -s $HOME/dotfiles/.vimrc $HOME/.vimrc
ln -s $HOME/dotfiles/.vimshrc $HOME/.vimshrc
ln -s $HOMW/dotfiles/.zshrc $HOME/.zshrc

#Homebrew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew update
brew install fontforge
brew install lua
brew install vim --with-lua

#Ricty
git clone https://github.com/yascentur/Ricty.git $HOME/Ricty
cd $HOME/Ricty
curl -L -o Inconsolata.otf "http://levien.com/type/myfonts/Inconsolata.otf"
curl -L -o migu-1m.zip "http://sourceforge.jp/frs/redir.php?m=jaist&f=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip"
unzip -j migu-1m.zip
sh ricty_generator.sh Inconsolata.otf migu-1m-regular.ttf migu-1m-bold.ttf
cp -f Ricty*.ttf $HOME/.fonts/
% fc-cache -vf
cd $HOME
rm -rf $HOME/Ricty

#zsh
chsh -s /bin/zsh
