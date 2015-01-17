# dotfiles
[![](http://img.shields.io/github/issues/844196/dotfiles.svg?style=flat)](https://github.com/844196/dotfiles/issues)
[![](http://img.shields.io/badge/license-WTFPL-red.svg?style=flat)](LICENSE)

![](https://farm8.staticflickr.com/7551/16119611580_c5c31227e7_b.jpg)

## Installation
### setup.sh
```shellsession
$ curl -sL 844196.com/dot | bash
```

#### Features
- IF: Init
    - Clone dotfiles
    - Make symbolic link
    - Install plugin
        - zsh-syntax-highlighting
        - neobundle.vim
- Else
    - Sync dotfiles remote branch
    - Execute `brew update && brew upgrade`

*note* : This setup script **does not** provide the Homebrew installation process.

## Local settings
### .vimrc_local
```vim
" Colorscheme
if neobundle#tap('gruvbox')
    set bg=dark
    colorscheme gruvbox
    if has('gui_running')
        autocmd MyAutoCmd GUIEnter * colorscheme gruvbox
    endif

    let g:gruvbox_italic = 0

    call neobundle#untap()
endif

if neobundle#tap('lightline-gruvbox.vim')
    let g:lightline.colorscheme = 'gruvbox'

    call neobundle#untap()
endif

" Unicode Symbols
let g:rich_symbols = '1'
```
