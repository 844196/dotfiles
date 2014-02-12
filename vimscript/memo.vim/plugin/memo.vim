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
    let s:title = input('Title: ')

    let s:filename = g:memopath . strftime('%Y-%m-%d_') . s:title . '.md'

    let s:template = [
                \'# ' . s:title,
                \'date : ' . strftime("%Y-%m-%d"),
                \'',
                \'',
                \]

    execute 'new ' . s:filename
    call setline(1, s:template)
    execute '999'
    execute 'write'
endfunction

command! -nargs=0 MemoNew call s:open_memo_file()


"メモ一覧呼び出し
command! -nargs=0 MemoList :Unite memo -buffer-name=memo_list -winheight=10 -max-multi-lines=1

"メモgrep
command! -nargs=0 MemoGrep :execute('Unite grep:' . g:memopath . ' -no-quit')


"読み込み前の&cpoの値を読み込み
let &cpo = s:save_cpo
"作業用変数を削除
unlet s:save_cpo
