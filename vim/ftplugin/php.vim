if exists('b:did_ftplugin')
    finish
endif

setlocal iskeyword+=$
setlocal iskeyword-=-

setlocal noexpandtab
setlocal tabstop=4 shiftwidth=4

setlocal makeprg=phan
setlocal errorformat=%f:%l\ %m

let b:did_ftplugin = 1
