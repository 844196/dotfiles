if exists('b:did_after_ftplugin')
    finish
endif

" 画面に収まりきらなくても折り返さない
setlocal nowrap

let b:did_after_ftplugin = 1
