if exists('b:did_ftplugin')
    finish
endif

wincmd L
nnoremap <silent><buffer>q :q<CR>

let b:did_ftplugin = 1
