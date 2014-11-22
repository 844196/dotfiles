# dotfiles

## Installation
### Easy
```shellsession
$ curl -sL 844196.com/dot | sh
```

### Manual
```shellsession
$ git clone https://github.com/844196/dotfiles ~/dotfiles
```

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
