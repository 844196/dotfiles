"ち～ん（笑）って鳴らさない
set visualbell t_vb=

"行数とか
set columns=100
set lines=48

"フォントとか
set guifont=Ricty\ Regular\ for\ Powerline:h18
set antialias

"スクロールバーとか表示しない
set guioptions-=T
set guioptions-=r
set guioptions-=L

"カラースキームの設定
colorscheme solarized
set bg=light
let g:solarized_visibilty = "high"
let g:solarized_contrast = "high"

"日本語入力ON時のカーソルの色を設定
".vimrcに書いても有効にならなかったからこっちへ
if has('multi_byte_ime') || has('xim')
    highlight CursorIM guibg=Green guifg=NONE
endif
