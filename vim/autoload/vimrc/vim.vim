let s:saveCpo = &cpo
set cpo&vim

function! vimrc#vim#invokeCommand(command) abort
    let s:tempFile = tempname()
    try
        call writefile([a:command], s:tempFile)
        execute 'source' fnameescape(s:tempFile)
    catch /E486/
        " 握りつぶす
    finally
        if filereadable(s:tempFile)
            call delete(s:tempFile)
        endif
    endtry
endfunction

function! vimrc#vim#mkdirp(path) abort
    if isdirectory(a:path) == v:false
        call mkdir(a:path, 'p')
    endif
endfunction

let &cpo = s:saveCpo
unlet s:saveCpo
