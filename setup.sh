#!/bin/sh


# 導入するドットファイルを宣言

    dotfiles=(.vimrc .gvimrc .vimshrc .zshrc .zshenv .tmux.conf .gitconfig .gitignore_global)


# 環境の判定

    if [ $(uname) = 'Darwin' ]; then ismac='0'; fi


# ドットファイルをクローン

    git clone https://github.com/844196/dotfiles ~/dotfiles


# ドットファイルのシンボリックリンクを作成

    for file in ${dotfiles[@]}; do
        ln -s ~/dotfiles/${file} ~/${file}
    done


# NeoBundleをインストール

    if which git >/dev/null 2>&1; then
        if ! [ -e ~/.vim/bundle/neobundle.vim ]; then
            mkdir -p ~/.vim/bundle
            git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
        fi
    fi


# Macなら以下を実行

    if [ -n "${ismac}" ]; then
        # Homebrewをインストール
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

        # ClipMenu拡張のシンボリックリンクを張る
        mkdir -p ~/Library/Application\ Support/ClipMenu/script/action
        cp ~/dotfiles/javascript/*.js ~/Library/Application\ Support/ClipMenu/script/action

        # Karabinerリマップのシンボリックリンクを張る
        mkdir -p ~/Library/Application\ Support/Karabiner
        ln -s ~/dotfiles/private.xml ~/Library/Application\ Support/Karabiner/private.xml
    fi
