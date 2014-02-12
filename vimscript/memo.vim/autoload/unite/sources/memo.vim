"g:loaded_logが読み込めたら、以降のコードを読み込まない
if exists("g:loaded_memo")
  finish
endif
"g:loaded_logを宣言
let g:loaded_memo = 1

"読み込み前の&cpo(設定値)を格納後、vimの初期値に戻す
let s:save_cpo = &cpo
set cpo&vim


"メモ作成
function! s:open_memo_file()
    let l:title = input('Title: ')

    let l:filename = g:memopath . strftime('%Y-%m-%d_') . l:title . '.md'

    let l:template = [
                \'# ' . l:title,
                \'date : ' . strftime("%Y-%m-%d"),
                \'',
                \'',
                \]

    execute 'new ' . l:filename
    call setline(1, l:template)
    execute '999'
    execute 'write'
endfunction

command! -nargs=0 MemoNew call s:open_memo_file()


"メモ一覧
let s:memo = { 'name': 'memo' }

function! s:memo.gather_candidates(args, context)
    let list = glob(g:memopath . "*.md")

    let c1 = substitute(list, '\/Users\/s083027\/Dropbox\/Memo\/', '', 'g')
    let c2 = split(c1, "\n")
    call remove(c2, match(c2, "ToDo.md"))
    let c3 = join(c2, "\n")

    let c4 = substitute(c3, '20\d.-\(0\|1\)\d-\(0\|1\|2\|3\)\d\zs_\ze.*\.md', ' | ', 'g')
    let c5 = substitute(c4, '\.md', '', 'g')
    let c6 = split(c5, "\n")

    return map(c2, '{
        \ "word": v:val,
        \ "source": c5,
        \ "kind": "file",
        \ "action__path": g:memopath . v:val,
        \ "action__line": v:key + 1,
        \ }')
endfunction

call unite#custom_source('memo', 'sorters', 'sorter_reverse')

function! unite#sources#memo#define()
    return s:memo
endfunction


"メモ一覧呼び出し
command! -nargs=0 MemoList :Unite memo -buffer-name=memo_list -winheight=10 -max-multi-lines=1

"メモgrep
command! -nargs=0 MemoGrep :execute('Unite grep:' . g:memopath . ' -no-quit')


"読み込み前の&cpoの値を読み込み
let &cpo = s:save_cpo
"作業用変数を削除
unlet s:save_cpo
