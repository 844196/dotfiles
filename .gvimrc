" 行数指定
set lines=52

" フォント
if g:iswin
    set guifont=MS_Gothic:h11:cSHIFTJIS
elseif g:ismac
    set guifont=Ricty\ Regular\ for\ Powerline:h17
elseif g:isunix
    set guifont=DejaVu\ Sans\ Mono\ 11
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

" colorscheme
if neobundle#tap('badwolf')
    colorscheme badwolf

    call neobundle#untap
endif
