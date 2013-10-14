"==================================================================
"基本設定 {{{

"vi互換をオフする
set nocompatible

"スワップ・バックアップを作成しない
set noswapfile
set nobackup

"augroup設定
augroup MyAutoCmd
    autocmd!
augroup END

"<space>evで.vimrcを編集
nnoremap <Space>ev :<C-u>edit $MYVIMRC<CR>

".vimrcを自動再読み込み
autocmd MyAutoCmd BufWritePost $MYVIMRC nested source $MYVIMRC

"<C-h>でヘルプを引く
nnoremap <C-h> :<C-u>help<Space>

"Windows環境用変数宣言
let s:iswin = has('win32') || has('win64') || has('win32unix')

"Mac環境用変数宣言
let s:ismac = has('mac')

"unix環境用変数宣言
let s:isunix = has('unix')


"}}}
"==================================================================
"表示設定 {{{

"シンタックス有効
syntax on

"モードラインを有効にする
set modeline

"モードライン3行目までを検索
set modelines=3

"ステータスラインを常に表示
set laststatus=2

"コマンドラインを2行に設定
set cmdheight=2

"ターミナルの場合は256色指定
if !has('gui_running')
    set t_Co=256
endif

"ターミナルの場合はdesertを使用
if !has('gui_running')
    colorscheme desert
endif

"スクロール時に5行を確保
set scrolloff=10

"行番号を表示する
set number

"コマンド補完
set wildmenu

"相対行番号を表示
nnoremap <silent><F3> :<C-u>setlocal relativenumber!<CR>

"行数指定
if has('gui_running')
    autocmd MyAutoCmd GUIEnter * set lines=52
endif

"カーソル位置をハイライト
set cursorline

"閉括弧が入力された時、対応する括弧を強調する
set showmatch

"入力中のコマンドを下に表示
set showcmd

"不可視文字を表示
set list
if !s:iswin
    set listchars=tab:»-,trail:-,eol:¬,nbsp:%
endif

"フォント
if s:iswin
    autocmd MyAutoCmd GUIEnter * set guifont=MS_Gothic:h11:cSHIFTJIS
elseif s:ismac
    autocmd MyAutoCmd GUIEnter * set guifont=Ricty\ Regular:h17
elseif s:isunix
    autocmd MyAutoCmd GUIEnter * set guifont=DejaVu\ Sans\ Mono\ 11
endif

"gvimの時はフォントを綺麗にする
if has('gui_running')
    autocmd MyAutoCmd GUIEnter * set antialias
endif

"スクロールバーとか表示しない
if has('gui_running')
    autocmd MyAutoCmd GUIEnter * set guioptions=NONE
endif

"<Right>でウィンドウを右に伸ばす <Left>で戻す
if has('gui_running')
    if has('kaoriya')
        nnoremap <silent><Right> :<C-u>SM 2<CR>
        nnoremap <silent><Left> :<C-u>SM 0<CR>
    else
        nnoremap <silent><Right> :<C-u>set columns=161<CR>
        nnoremap <silent><Left> :<C-u>set columns=80<CR>
    endif
endif


"}}}
"==================================================================
"インデント設定 {{{

"タブの代わりに空白文字を指定する
set expandtab

"Tabはスペース4つに変換
"BackSpace押したらスペース4つ消せるよ
set tabstop=4
set shiftwidth=4

"新しい行を作った時に高度な自動インデントを行う
set smarttab

"新しい行のインデントを現在行と同じにする
set autoindent

"}}}
"==================================================================
"検索設定 {{{

"インクリメンタルサーチを行う
set incsearch

"最後まで検索したら最初にワープしない
set nowrapscan

"検索結果のハイライトをEsc連打でクリアする
nnoremap <ESC><ESC> :nohlsearch<CR>


"}}}
"==================================================================
"ファイル設定 {{{

"markdownファイルのシンタックス関連付け
autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown

" tmpファイル
command! -nargs=1 -complete=filetype Tmp edit ~/tmp.<args>
nnoremap <F2> :<C-u>Tmp md<CR>

"}}}
"==================================================================
"レジスタ・クリップボード設定 {{{

"内容確認
nnoremap R :<C-u>registers<CR>

"クリップボード連携
if has('gui_running')
    set clipboard&
    set clipboard+=unnamed
endif


"}}}
"==================================================================
"編集設定 {{{

"変更中のファイルでも、保存しないで他のファイルを表示する
set hidden

"右に開く
set splitright

"ノーマルモードでEnterを押すと空行を挿入
noremap <CR> o<ESC>
noremap <S-CR> O<ESC>

";と:を入れ替える
nnoremap : ;
nnoremap ; :

"<Space>でコマンドライン
nnoremap <Space> :<C-u>
vnoremap <Space> :<C-u>

"カッコ系を入力したら自動で中にカーソルを移動させる
imap {} {}<Left>
imap [] []<Left>
imap "" ""<Left>
imap '' ''<Left>
imap <> <><Left>
imap () ()<Left>

"insert modeでjjでnormal modeへ
inoremap jj <Esc>

"<S-Space>でnormal modeへ
inoremap <S-Space> <Esc>

"insertモードを抜けるとIMEオフ
if has('multi_byte_ime') || has('xim')
    set iminsert=0
    set imsearch=0
    inoremap <silent><ESC> <ESC>
endif

"ち～ん（笑）って鳴らさない
if has('gui_running')
    autocmd MyAutoCmd GUIEnter * set visualbell t_vb=
else
    set visualbell
    set t_vb=
endif

"<Space>vsで縦分割後、新しいバッファに移動
nnoremap <Space>vs :<C-u>vsplit\|winc l<CR>

"バッファを選択する際に、同時にリストを表示する
"http://qiita.com/s_of_p/items/a80020cf32f3de5d044c
nnoremap B :<C-u>ls<CR>:b


"}}}
"==================================================================
"スパウザー {{{

function! Scouter(file, ...)
  let pat = '^\s*$\|^\s*"'
  let lines = readfile(a:file)
  if !a:0 || !a:1
    let lines = split(substitute(join(lines, "\n"), '\n\s*\\', '', 'g'), "\n")
  endif
  return len(filter(lines,'v:val !~ pat'))
endfunction
command! -bar -bang -nargs=? -complete=file Scouter
\        echo Scouter(empty(<q-args>) ? $MYVIMRC : expand(<q-args>), <bang>0)


"}}}
"==================================================================
"プラグイン設定 {{{

"NeoBundleがある時だけ以下を読み込み
if glob('~/.vim/bundle/neobundle.vim') != ''

    "初期化
    filetype off

    if has('vim_starting')
        set runtimepath+=~/.vim/bundle/neobundle.vim/
        call neobundle#rc(expand('~/.vim/bundle/'))
    endif

    "NeoBundle自体
    NeoBundleFetch 'Shougo/neobundle.vim'

    "プラグイン
    NeoBundle 'itchyny/lightline.vim'
    NeoBundle 'lilydjwg/colorizer'
    NeoBundle 'Shougo/vimproc', {
          \ 'build' : {
          \     'windows' : 'make -f make_mingw32.mak',
          \     'cygwin' : 'make -f make_cygwin.mak',
          \     'mac' : 'make -f make_mac.mak',
          \     'unix' : 'make -f make_unix.mak',
          \    },
          \ }
    NeoBundle 'Shougo/vimshell.vim'
    NeoBundle 'ujihisa/vimshell-ssh'
    NeoBundle 'basyura/TweetVim'
    NeoBundle 'tyru/open-browser.vim'
    NeoBundle 'basyura/twibill.vim'

    "カラースキーム
    NeoBundle 'altercation/vim-colors-solarized'
    NeoBundle 'w0ng/vim-hybrid'
    NeoBundle 'cocopon/lightline-hybrid.vim'

    "事後
    filetype plugin indent on


"}}}
"==================================================================
"lightline.vim {{{

    "hybridテーマを使用
    let g:lightline = {}
    let g:lightline.colorscheme = 'hybrid'
    autocmd MyAutoCmd VimEnter * call lightline#colorscheme()

    "lightline入れてるからモードを表示させない
    set noshowmode


"}}}
"==================================================================
"TweetVim {{{

    "<Space>tsでツイートバッファを表示
    nnoremap <Space>ts :<C-u>TweetVimSay<CR>

    "<Space>thでタイムラインを表示
    nnoremap <Space>th :<C-u>TweetVimHomeTimeline<CR>


"}}}
"==================================================================
"VimSell {{{

    "<Leader>sでVimShellを開く
    nnoremap <silent><Leader>s :<C-u>VimShell<CR>


"}}}
"==================================================================
"colorscheme {{{

    "hybridを使用
    if has('gui_running')
        autocmd MyAutoCmd GUIEnter * colorscheme hybrid
    else
        colorscheme hybrid
    endif

    "日本語入力時のカーソル色を変更
    if has('multi_byte_ime') || has('xim')
        autocmd MyAutoCmd GUIEnter * highlight Cursor guifg=NONE guibg=#cc6666
        autocmd MyAutoCmd GUIEnter * highlight CursorIM guifg=NONE guibg=#b5bd68
    endif


"}}}
"==================================================================

endif

"}}}
"==================================================================
"vimrc_local設定 {{{

"vimrc_localがあったら読み込む
if filereadable(expand($HOME.'/.vimrc_local'))
    source $HOME/.vimrc_local

    "<Space>elで.vimrc_localを編集
    nnoremap <Space>el :<C-u>edit $HOME/.vimrc_local<CR>

    ".vimrc_localを編集したら自動再読み込み
    autocmd MyAutoCmd BufWritePost $HOME/.vimrc_local nested source $HOME/.vimrc_local
endif


"}}}
"==================================================================
" vim: foldmethod=marker
