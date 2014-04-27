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

"<C-Tab>でタブ切り替え
nnoremap <C-Tab> gt

"stで新しいタブ
nnoremap st :tabnew<CR>


"}}}
"==================================================================
"インデント設定 {{{

"タブの代わりに空白文字を指定する
set expandtab

"Tabはスペース4つに変換
"BackSpace押したらスペース4つ消せるよ
set tabstop=4
set shiftwidth=4

"HTMLとCSSのときはインデントをスペース2つへ
autocmd! MyAutoCmd FileType html setlocal tabstop=2 shiftwidth=2
autocmd! MyAutoCmd FileType css setlocal tabstop=2 shiftwidth=2

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

"大文字、小文字を区別しない
set ignorecase

"検索語句を画面中央に
nnoremap n nzz
nnoremap N Nzz


"}}}
"==================================================================
"ファイル設定 {{{

"markdownファイルのシンタックス関連付け
autocmd MyAutoCmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown

" tmpファイル
command! -nargs=1 -complete=filetype Tmp edit $HOME/tmp.<args>

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

"JとgJを入れ替える
nnoremap J gJ
nnoremap gJ J

"方向キーでバッファの大きさを変える
nnoremap <Right> <C-w>>
nnoremap <Left> <C-w><
nnoremap <Up> <C-w>+
nnoremap <Down> <C-w>-


"}}}
"==================================================================
"Vim Script {{{

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

"ToDoとか {{{
function! s:ToggleDone(line)
    if a:line =~ '^"*\s*\[D\]'
        call setline('.', substitute(a:line, '\[D\]<.*>', '\[ \]', ''))
    else
        call setline('.', substitute(a:line, '\[ \]', '[D]<' . strftime("%Y/%m/%d %H:%M") . '>', ''))
    endif
endfunction
command! -nargs=0 ToggleDone call s:ToggleDone(getline('.'))
nnoremap <Space>td :<C-u>ToggleDone<CR>

nnoremap <F1> :<C-u>edit ~/DropBox/Memo/ToDo.md<CR>
"}}}

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
    NeoBundle 'mattn/webapi-vim'
    NeoBundle 'thinca/vim-quickrun'
    NeoBundle 'thinca/vim-splash'
    NeoBundle 'Shougo/unite.vim'
    NeoBundle 'nathanaelkane/vim-indent-guides'
    NeoBundle 'h1mesuke/unite-outline'
    NeoBundle 'Shougo/neocomplete.vim'
    NeoBundle 'mattn/emmet-vim'

    "自作
    NeoBundle 'memo.vim', {
        \ 'base' : '~/dotfiles/vimscript',
        \ 'type' : 'nosync'
        \ }
    NeoBundle 'Log.vim', {
        \ 'base' : '~/dotfiles/vimscript',
        \ 'type' : 'nosync'
        \ }
    NeoBundle 'lightline-badwolf.vim', {
        \ 'base' : '~/dotfiles/vimscript',
        \ 'type' : 'nosync'
        \ }

    "カラースキーム
    NeoBundle 'altercation/vim-colors-solarized'
    NeoBundle 'w0ng/vim-hybrid'
    NeoBundle 'cocopon/lightline-hybrid.vim'
    NeoBundle 'ujihisa/unite-colorscheme'

    "事後
    filetype plugin indent on


    "lightline.vim {{{
        "hybridテーマを使用
        let g:lightline = {}
        let g:lightline.colorscheme = 'badwolf'
        autocmd MyAutoCmd VimEnter * call lightline#colorscheme()

        "lightline入れてるからモードを表示させない
        set noshowmode
    "}}}

    "TweetVim {{{
        "<Space>tsでツイートバッファを表示
        nnoremap <Space>ts :<C-u>TweetVimSay<CR>

        "<Space>thでタイムラインを表示
        nnoremap <Space>th :<C-u>TweetVimUserStream<CR>

        "空文字セパレートを表示
        let g:tweetvim_display_separator = 1
        let g:tweetvim_empty_separator = 1

        "スクリーンネームを表示
        let g:tweetvim_display_username = 1

        "アイコンを表示
        if has('gui_running') || has('mac')
            " 1.環境設定→詳細→`Core Textレンダラを使用する`をオフにしてMacVim.appを終了させる
            " 2.MacVim.appを開きなおして、`Core Text〜`をオンにしてもっかい終了
            " 3.最後に開き直すと表示される。
            let g:tweetvim_display_icon = 1
        endif
    "}}}

    "VimSell {{{
        "<Leader>sでVimShellを開く
        nnoremap <silent><Leader>s :<C-u>VimShell<CR>

        "プロンプトを標識に
        let g:prompt = "(๑•﹏•) "
        let g:vimshell_prompt_expr = 'g:prompt.getcwd()." $ "'
        let g:vimshell_prompt_pattern = '^(๑•﹏•)\ \f\+ $ '
    "}}}

    "colorscheme {{{
        "hybridを使用
        if has('gui_running')
            autocmd MyAutoCmd GUIEnter * colorscheme badwolf
        else
            colorscheme badwolf
        endif

        "日本語入力時のカーソル色を変更
        if has('multi_byte_ime') || has('xim')
            autocmd MyAutoCmd GUIEnter * highlight Cursor guifg=NONE guibg=#cc6666
            autocmd MyAutoCmd GUIEnter * highlight CursorIM guifg=NONE guibg=#b5bd68
        endif
    "}}}

    "vim-splash {{{
        "splash.txtの場所
        let g:splash#path = $HOME.'/dotfiles/splash.txt'
    "}}}

    "vim-quickrun {{{
        let g:quickrun_config = {}
        let g:quickrun_config = {
                    \   "_" : {
                    \       "outputter/buffer/split" : ":botright 8sp",
                    \       "outputter/buffer/close_on_empty" : 1,
                    \       "runner" : "vimproc",
                    \       "runner/vimproc/updatetime" : 60
                    \   },
                    \   "markdown" : {
                    \       "outputter" : "null",
                    \       "command"   : "open",
                    \       "cmdopt"    : "-a",
                    \       "args"      : "Marked",
                    \       "exec"      : "%c %o %a %s",
                    \   },
                    \ }
    "}}}

    "Unite {{{
        "バッファ一覧をUniteに置き換え
        nnoremap B :<C-u>Unite<Space>buffer<CR>

        "<Leader><Leader>でUnite file
        nnoremap <Leader><Leader> :Unite file<CR>

        "インサートモードオン
        let g:unite_enable_start_insert = 1

    "}}}

    "Unite-outline {{{
        "アウトラインのインデントを4つへ
        let g:unite_source_outline_indent_width = 4
    "}}}

    "memo.vim {{{
        "メモディレクトリを宣言
        let g:memopath = '~/Dropbox/Memo/'

        "メモ一覧呼び出しリマップ
        nnoremap <F2> :MemoList<CR>
    "}}}

    "Log.vim {{{
        "<Space>htで入力待機
        nnoremap <Space>ht :<C-u>Htag 

        "<space>ciで<div class="caption"></div>を挿入
        nnoremap <silent><Space>ci :<C-u>LogCaption<CR>

        "<Space>imで標準置換、<Space>icでCC置換
        nnoremap <silent><Space>im :<C-u>F2M NO<CR>
        nnoremap <silent><Space>ic :<C-u>F2M CC<CR>

        "メモディレクトリを宣言
        let g:logpath = '~/Dropbox/Log/_posts/'
    "}}}

    "vim-indent-guides {{{
        "ガイドラインの色を変更
        let g:indent_guides_auto_colors=0
        autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
        autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4

        "ガイドラインの大きさを1に変更
        let g:indent_guides_guide_size=1

        "<F5>でガイドの表示切り替え
        nnoremap <silent><F5> :IndentGuidesToggle<CR>
    "}}}

    "neocomplete {{{
        "Vim起動時から補完スタート
        let g:neocomplete#enable_at_startup = 1

        "<F4>で補完切り替え
        nnoremap <F4> :NeoCompleteToggle<CR>
    "}}}

    "emmet-vim {{{
        "スニペット言語設定
        let g:user_emmet_settings = {
                \ 'lang' : 'ja'
                \ }
    "}}}


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
