#!/bin/sh

cd $HOME
git clone https://github.com/yascentur/Ricty.git
git clone https://github.com/Lokaltog/vim-powerline.git

cd $HOME/Ricty
curl -L -o Inconsolata.otf "http://levien.com/type/myfonts/Inconsolata.otf"
curl -L -o migu-1m.zip "http://sourceforge.jp/frs/redir.php?m=jaist&f=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip"
unzip -j migu-1m.zip

sh ricty_generator.sh Inconsolata.otf migu-1m-regular.ttf migu-1m-bold.ttf
fontforge -lang=py -script $HOME/vim-powerline/fontpatcher/fontpatcher $HOME/Ricty/Ricty-Regular.ttf
fontforge -lang=py -script $HOME/vim-powerline/fontpatcher/fontpatcher $HOME/Ricty/Ricty-Bold.ttf

cp Ricty*.ttf $HOME/Library/Fonts/
cd $HOME
rm -rf $HOME/Ricty $HOME/vim-powerline
