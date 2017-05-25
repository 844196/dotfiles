if exists('b:current_syntax')
    finish
endif

syntax match vimsplash_highlight_a 'a'
syntax match vimsplash_highlight_b 'b'
syntax match vimsplash_highlight_c 'c'
syntax match vimsplash_highlight_d 'd'
syntax match vimsplash_highlight_e 'e'
syntax match vimsplash_highlight_f 'f'
syntax match vimsplash_highlight_g 'g'
syntax match vimsplash_highlight_h 'h'
syntax match vimsplash_highlight_i 'i'
syntax match vimsplash_highlight_j 'j'
syntax match vimsplash_highlight_k 'k'
syntax match vimsplash_highlight_l 'l'
syntax match vimsplash_highlight_m 'm'
highlight vimsplash_highlight_a ctermbg=232 ctermfg=232 guifg=#000000 guibg=#000000
highlight vimsplash_highlight_b ctermbg=79 ctermfg=79 guifg=#5abe8b guibg=#5abe8b
highlight vimsplash_highlight_c ctermbg=62 ctermfg=62 guifg=#757da0 guibg=#757da0
highlight vimsplash_highlight_d ctermbg=254 ctermfg=254 guifg=#ffffff guibg=#ffffff
highlight vimsplash_highlight_e ctermbg=246 ctermfg=246 guifg=#bdc39f guibg=#bdc39f
highlight vimsplash_highlight_f ctermbg=249 ctermfg=249 guifg=#dae5c5 guibg=#dae5c5
highlight vimsplash_highlight_g ctermbg=237 ctermfg=237 guifg=#293831 guibg=#293831
highlight vimsplash_highlight_h ctermbg=239 ctermfg=239 guifg=#51655a guibg=#51655a
highlight vimsplash_highlight_i ctermbg=241 ctermfg=241 guifg=#647974 guibg=#647974
highlight vimsplash_highlight_j ctermbg=223 ctermfg=223 guifg=#ffdfb6 guibg=#ffdfb6
highlight vimsplash_highlight_k ctermbg=124 ctermfg=124 guifg=#8c4939 guibg=#8c4939
highlight vimsplash_highlight_l ctermbg=160 ctermfg=160 guifg=#9b5445 guibg=#9b5445
highlight vimsplash_highlight_m ctermbg=95 ctermfg=95 guifg=#645142 guibg=#645142

let b:current_syntax = 'vim-splash'
