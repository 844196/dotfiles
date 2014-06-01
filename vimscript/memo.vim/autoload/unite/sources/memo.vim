"読み込み前の&cpo(設定値)を格納後、vimの初期値に戻す
let s:save_cpo = &cpo
set cpo&vim

"メモ一覧
let s:memo = { 'name': 'memo' }

let s:filter = {
            \ 'name' : 'my_filter'
            \ }

function! s:filter.filter(candidates, context)
    for candidates in a:candidates
        let memo = candidates.source__memo
        let candidates.word = printf("%-60S - %10S", memo.title, memo.date)
    endfor
    return a:candidates
endfunction
call unite#define_filter(s:filter)

function! s:memopath()
    return expand(g:memopath)
endfunction

function! s:all_memo()
    let list = split(glob(s:memopath() . "/*.md"), "\n")
    return map(list, '{
                \ "date" : fnamemodify(v:val, ":t:r")[0:9],
                \ "title" : substitute(fnamemodify(v:val, ":t:r"), "^....-..-.._", "", ""),
                \ "path" : v:val
                \ }')
endfunction

function! s:memo.gather_candidates(args, context)
    let ret = []
    for val in s:all_memo()
        let candidates = {
                    \ "word" : val.title,
                    \ "source" : "memo",
                    \ "kind" : "file",
                    \ "action__path" : val.path,
                    \ "source__memo" : val
                    \ }
        call add(ret, candidates)
    endfor
    return ret
endfunction
call unite#custom_source('memo', 'sorters', 'sorter_reverse')
call unite#custom_source('memo', 'converters', 'my_filter')

function! unite#sources#memo#define()
    return s:memo
endfunction

"読み込み前の&cpoの値を読み込み
let &cpo = s:save_cpo
"作業用変数を削除
unlet s:save_cpo
