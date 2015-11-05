" set encoding UTF-8
set encoding=utf-8
scriptencoding utf-8

" 行数指定
set lines=52

" フォント
if g:iswin
    set guifont=MS_Gothic:h11:cSHIFTJIS
elseif g:ismac
    set guifont=Ricty\ Regular\ for\ Powerline:h10
elseif g:isunix
    set guifont=DejaVu\ Sans\ Mono\ 09
endif

" gvimの時はフォントを綺麗にする
set antialias

" スクロールバーとか表示しない
set guioptions=NONE

" クリップボード連携
set clipboard&
set clipboard+=unnamed

" ち～ん（笑）って鳴らさない
set visualbell t_vb=
