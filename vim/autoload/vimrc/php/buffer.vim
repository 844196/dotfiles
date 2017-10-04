let s:saveCpo = &cpo
set cpo&vim

function! s:match(regexp) abort
    let s:seeker = 1
    while s:seeker <= line('$')
        let s:matched = matchlist(getline(s:seeker), a:regexp)
        if len(s:matched) != 0
            return s:matched
        endif
        let s:seeker += 1
    endwhile

    return []
endfunction

function! vimrc#php#buffer#parseNamespace() abort
    return get(s:match('\v^namespace\s+([^;]+);$'), 1, '')
endfunction

function! vimrc#php#buffer#parseClassname() abort
    return get(s:match('\v^%(abstract\s+)?%(class|trait|interface)\s+(\w+).*$'), 1, '')
endfunction

function! vimrc#php#buffer#parseFullclass() abort
    let s:namespace = vimrc#php#buffer#parseNamespace()

    return s:namespace . (s:namespace == '' ? '' : '\') . vimrc#php#buffer#parseClassname()
endfunction

function! vimrc#php#buffer#write() abort
    let s:dstPath = input('Correct? ', 'src/' . tr(vimrc#php#buffer#parseFullclass(), '\', '/') . '.php')
    if s:dstPath == ''
        return
    endif

    let s:dstDir = fnamemodify(s:dstPath, ':p:h')
    if isdirectory(s:dstDir) == v:false
        call mkdir(s:dstDir, 'p')
    endif

    execute expand('%') == ''
        \ ? 'confirm w ' . s:dstPath
        \ : 'f ' . s:dstPath . ' | call delete(expand("#")) | w'
endfunction

function! vimrc#php#buffer#sortUses() abort
    let s:curPos = getcurpos() | 0

    let s:regexp = '\v^use [^;]+;$'
    let s:start = search(s:regexp, 'cnW')
    let s:end = s:start

    let s:seeker = s:start
    while s:seeker <= line('$') + 1
        if match(getline(s:seeker), s:regexp) == -1
            let s:end = s:seeker - 1
            break
        endif
        let s:seeker += 1
    endwhile

    if s:start > 1 && s:end > s:start
        execute s:start . ',' . s:end . 'sort u'
    endif

    call setpos('.', s:curPos)
endfunction

function! vimrc#php#buffer#addUses(uses) abort
    if len(a:uses) == 0
        return
    endif

    let s:beforeWinId = win_getid() | silent! below 1sp | 0
    try
        let s:candidates = [
            \ {
            \   'regexp': '\v^use [^;]+;$',
            \   'isRequiredMargin': v:false,
            \ },
            \ {
            \   'regexp': '\v^namespace [^;]+;$',
            \   'isRequiredMargin': v:true,
            \ },
            \ {
            \   'regexp': '\v^declare\([^\)]+\);$',
            \   'isRequiredMargin': v:true,
            \ },
            \ {
            \   'regexp': '\v^<\?php$',
            \   'isRequiredMargin': v:true,
            \ },
            \ ]

        let s:insertPos = 1
        let s:isRequiredMargin = v:true
        for s:candidate in s:candidates
            let s:matched = search(s:candidate.regexp, 'cnW')
            if s:matched != 0
                let s:insertPos = s:matched
                let s:isRequiredMargin = s:candidate.isRequiredMargin
                break
            endif
        endfor

        if s:isRequiredMargin == v:true
            call append(s:insertPos, '')
        endif

        call append(
            \ s:insertPos + (s:isRequiredMargin == v:true ? 1 : 0),
            \ a:uses
            \ )

        call vimrc#php#buffer#sortUses()
    finally
        q
        call win_gotoid(s:beforeWinId)
    endtry
endfunction

let &cpo = s:saveCpo
unlet s:saveCpo
