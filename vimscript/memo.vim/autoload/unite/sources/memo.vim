"読み込み前の&cpo(設定値)を格納後、vimの初期値に戻す
let s:save_cpo = &cpo
set cpo&vim

"メモ一覧
let s:memo = { 'name': 'memo' }

function! s:memo.gather_candidates(args, context)
    let s:list = glob(g:memopath . "*.md")

    let s:c1 = substitute(s:list, '\/Users\/s083027\/Dropbox\/Memo\/', '', 'g')
    let s:c2 = split(s:c1, "\n")
    call remove(s:c2, match(s:c2, "ToDo.md"))
    let s:c3 = join(s:c2, "\n")

    let s:c4 = substitute(s:c3, '20\d.-\(0\|1\)\d-\(0\|1\|2\|3\)\d\zs_\ze.*\.md', ' | ', 'g')
    let s:c5 = substitute(s:c4, '\.md', '', 'g')
    let s:c6 = split(s:c5, "\n")

    return map(s:c2, '{
        \ "word": v:val,
        \ "source": s:c5,
        \ "kind": "file",
        \ "action__path": g:memopath . v:val,
        \ "action__line": v:key + 1,
        \ }')
endfunction

call unite#custom_source('memo', 'sorters', 'sorter_reverse')

function! unite#sources#memo#define()
    return s:memo
endfunction

"読み込み前の&cpoの値を読み込み
let &cpo = s:save_cpo
"作業用変数を削除
unlet s:save_cpo
