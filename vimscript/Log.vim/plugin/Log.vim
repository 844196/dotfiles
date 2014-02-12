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
    let s:caption = '<center><i>' . s:title . '</i></center>'

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


function! s:Htag(tag)
    "カレント行の文字列を取得
    let s:line = getline('.')

    "前後を挟む形でa:tagを挿入
    call setline('.', '<' . a:tag . '>' . s:line . '</' . a:tag . '>')
endfunction

if !exists(':Htag')
    command! -bar -nargs=* Htag call s:Htag(<f-args>)
endif


"読み込み前の&cpoの値を読み込み
let &cpo = s:save_cpo
"作業用変数を削除
unlet s:save_cpo
