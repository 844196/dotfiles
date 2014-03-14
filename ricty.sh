#!/bin/sh

git clone https://github.com/yascentur/Ricty.git $HOME/Ricty
cd $HOME/Ricty
curl -L -o Inconsolata.otf "http://levien.com/type/myfonts/Inconsolata.otf"
curl -L -o migu-1m.zip "http://sourceforge.jp/frs/redir.php?m=jaist&f=%2Fmix-mplus-ipa%2F59022%2Fmigu-1m-20130617.zip"
unzip -j migu-1m.zip
sh ricty_generator.sh Inconsolata.otf migu-1m-regular.ttf migu-1m-bold.ttf
#sudo cp -f Ricty*.ttf $HOME/.fonts/
#fc-cache -vf
#cd $HOME
#rm -rf $HOME/Ricty
