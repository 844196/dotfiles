"g:loaded_logが読み込めたら、以降のコードを読み込まない
if exists("g:loaded_log")
  finish
endif
"g:loaded_logを宣言
let g:loaded_log = 1

"読み込み前の&cpo(設定値)を格納後、vimの初期値に戻す
let s:save_cpo = &cpo
set cpo&vim


function! s:F2M(args)
    "URL、画像への直リンク、タイトルを取得
    let s:url = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:"\[\]]*')
    let s:jpg = matchstr(getline("."), '[a-z]*:\/\/[^ >,;:\[\]]*\(png\|jpg\|jpeg\|gif\)')
    let s:title = matchstr(getline("."), 'title="\zs.*,\ on\ Flickr\ze">')

    "挿入する文字列を整形
    let s:mdimg = "[![](" . s:jpg . ")](" . s:url . ")"
    let s:caption = '<div class="caption">' . s:title . '</div>'

    "CCならキャプション込みで、NOならURLのみ
    if a:args == 'CC'
        call setline('.', s:mdimg)
        call append('.', s:caption)
    elseif a:args == 'NO'
        call setline('.', s:mdimg)
    else
        echo 'Option CC or NO only.'
    endif
endfunction

if !exists(':F2M')
    command! -nargs=* F2M call s:F2M(<f-args>)
endif

"タグを挿入するやつ
function! s:Htag(tag)
    "カレント行の文字列を取得
    let s:line = getline('.')

    "前後を挟む形でa:tagを挿入
    call setline('.', '<' . a:tag . '>' . s:line . '</' . a:tag . '>')
endfunction

if !exists(':Htag')
    command! -bar -nargs=* Htag call s:Htag(<f-args>)
endif

"<div class="caption"></div>を挿入するだけ
function! s:LogCaption()
    "カレント行の文字列を取得
    let s:line = getline('.')

    "前後を挟む形でa:tagを挿入
    call setline('.', '<div class="caption">' . s:line . '</div>')
endfunction

if !exists(':LogCaption')
    command! -bar -nargs=0 LogCaption call s:LogCaption()
endif


"新規記事作成
function! s:create_log_post()
    let s:title = input('Title: ')

    let s:filename = g:logpath . strftime('%Y-%m-%d-') . strftime('%Y%m%d%H%M%S') . '.md'
    let s:template = [
                \'---',
                \'layout: post',
                \'title: ' . s:title,
                \'date: ' . strftime('%Y-%m-%d %H:%M'),
                \'---',
                \'',
                \'',
                \]

    execute 'new ' . s:filename
    call setline(1, s:template)
    execute '999'
    execute 'write'
    execute 'only'
endfunction

command! -nargs=0 LogNew call s:create_log_post()

command! -nargs=0 LogGrep :execute('Unite grep:' . g:logpath . ' -no-quit')


"読み込み前の&cpoの値を読み込み
let &cpo = s:save_cpo
"作業用変数を削除
unlet s:save_cpo
