# dotfiles
[![](http://img.shields.io/badge/license-WTFPL-red.svg?style=flat)](LICENSE)

![](http://31.media.tumblr.com/6a28dc6e2524ca9a3015bc671433375b/tumblr_nfjv1yHiHB1s7qf9xo1_r1_1280.png)

## Installation
### Easy
```shellsession
$ curl -sL 844196.com/dot | sh
```

### Manual
```shellsession
$ git clone https://github.com/844196/dotfiles ~/dotfiles
```

## Local settings
### .vimrc_local
```vim
" Colorscheme
if neobundle#tap('badwolf')
    colorscheme badwolf
    call neobundle#untap()
endif

" Unicode Symbols
let g:vimrc_local_BranchSymbol = "\u2b60"
let g:vimrc_local_LinecolumnSymbol = "\u2b61"
let g:lightline.separator = {
            \ 'left' : "\u2b80", 'right' : "\u2b82"
            \ }
let g:lightline.subseparator = {
            \ 'left' : "\u2b81", 'right' : "\u2b83"
            \ }
```
