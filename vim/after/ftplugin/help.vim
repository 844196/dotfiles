if exists('b:did_after_ftplugin')
    finish
endif

wincmd L
nnoremap <silent><buffer>q :q<CR>

let b:did_after_ftplugin = 1
