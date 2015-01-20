" ==================================================================
" encoding {{{

" set encoding UTF-8
set encoding=utf-8
scriptencoding utf-8


" }}}
" ==================================================================
" 基本設定 {{{

" スワップ・バックアップ・アンドゥファイルを作成しない
set noswapfile
set nobackup
set noundofile

" augroup設定
augroup MyAutoCmd
    autocmd!
augroup END

" $MYVIMRC, $MYGVIMRC, viminfoを指定
let $MYVIMRC = resolve(expand('~/.vimrc'))
let $MYGVIMRC = resolve(expand('~/dotfiles/.gvimrc'))
set viminfo+=n~/.vim/.viminfo

" <space>evで.vimrcを、<space>egで.gvimrcを編集
nnoremap <Space>ev :<C-u>edit $MYVIMRC<CR>
nnoremap <Space>eg :<C-u>edit $MYGVIMRC<CR>

" .vimrcを自動再読み込み
autocmd MyAutoCmd BufWritePost $MYVIMRC nested source $MYVIMRC

" <C-h>でヘルプを引く
nnoremap <C-h> :<C-u>help<Space>

" qでヘルプを閉じる
autocmd! MyAutoCmd FileType help nnoremap <silent><buffer>q :quit<CR>

" Windows環境用変数宣言
let g:iswin = has('win32') || has('win64') || has('win32unix')

" Mac環境用変数宣言
let g:ismac = has('mac')

" unix環境用変数宣言
let g:isunix = has('unix')


" }}}
" ==================================================================
" 表示設定 {{{

" なんか早くなるらしい
set synmaxcol=300
set ttyfast

" モードラインを有効にする
set modeline

" モードライン3行目までを検索
set modelines=3

" ステータスラインを常に表示
set laststatus=2

" コマンドラインを2行に設定
set cmdheight=2

" ターミナルの場合は256色指定
if !has('gui_running')
    set t_Co=256
endif

" スクロール時に5行を確保
set scrolloff=10

" 行番号を表示する
set number

" コマンド補完
set wildmenu

" 相対行番号を表示
nnoremap <silent><F3> :<C-u>setlocal relativenumber!<CR>

" カレントバッファのカーソル位置をハイライト
autocmd MyAutoCmd BufLeave * setlocal nocursorline
autocmd MyAutoCmd BufEnter * setlocal cursorline

" 閉括弧が入力された時、対応する括弧を強調する
set showmatch

" 入力中のコマンドを下に表示
set showcmd

" 不可視文字を表示
set list
if g:ismac
    set listchars=tab:»-,trail:-,eol:¬,nbsp:%
else
    set listchars=trail:-
endif

" <C-Tab>でタブ切り替え
nnoremap <C-Tab> gt

" stで新しいタブ
nnoremap <Space>st :<C-u>tabnew<CR>

" iTermでインサートモード時、カーソルを正しく変形させる
if exists('$TMUX')
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    else
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" 折り返した行がインデントに沿うようになる
if has('patch-7.4.338')
    set breakindent
endif

" 行が長くてもとりあえず表示してくれる
set display=lastline

" Toggle Cursorcolumn Hilight
nnoremap <silent><Leader>c :<C-u>setlocal cursorcolumn!<CR>

" Toggle Colorcolumn
function! ToggleColorcolumn()
    if &colorcolumn !=? ''
        setlocal colorcolumn=
    else
        setlocal colorcolumn=100
    endif
endfunction
nnoremap <silent><Leader>1 :<C-u>call ToggleColorcolumn()<CR>


" }}}
" ==================================================================
" インデント設定 {{{

" タブの代わりに空白文字を指定する
set expandtab

" Tabはスペース4つに変換
" BackSpace押したらスペース4つ消せるよ
set tabstop=4
set shiftwidth=4

" HTMLとCSSのときはインデントをスペース2つへ
autocmd! MyAutoCmd FileType html setlocal tabstop=2 shiftwidth=2
autocmd! MyAutoCmd FileType css setlocal tabstop=2 shiftwidth=2

" 新しい行を作った時に高度な自動インデントを行う
set smarttab

" 新しい行のインデントを現在行と同じにする
set autoindent

" }}}
" ==================================================================
" 検索設定 {{{

" インクリメンタルサーチを行う
set incsearch

" 最後まで検索したら最初にワープしない
set nowrapscan

" 検索結果のハイライトをEsc連打でクリアする
nnoremap <silent><ESC><ESC> :<C-u>nohlsearch<CR>

" 大文字、小文字を区別しない
set ignorecase

" 検索語句を画面中央に
nnoremap n nzz
nnoremap N Nzz


" }}}
" ==================================================================
" ファイル設定 {{{

" markdownファイルのシンタックス関連付け
autocmd MyAutoCmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown

" fencedcode内でもシンタックスハイライト
let g:markdown_fenced_languages = [
            \ 'css',
            \ 'html',
            \ 'sh',
            \ 'vim'
            \ ]

"  tmpファイル
command! -nargs=1 -complete=filetype Tmp edit $HOME/tmp.<args>


" }}}
" ==================================================================
" 編集設定 {{{

" 変更中のファイルでも、保存しないで他のファイルを表示する
set hidden

" 右に開く
set splitright

" ノーマルモードでEnterを押すと空行を挿入
noremap <CR> o<ESC>
noremap <S-CR> O<ESC>

" <Space>でコマンドライン
noremap <Space> :

" カッコ系を入力したら自動で中にカーソルを移動させる
inoremap {} {}<Left>
inoremap [] []<Left>
inoremap "" ""<Left>
inoremap '' ''<Left>
inoremap <> <><Left>
inoremap () ()<Left>

" insertモードを抜けるとIMEオフ
if has('multi_byte_ime') || has('xim')
    set iminsert=0
    set imsearch=0
    inoremap <silent><ESC> <ESC>
endif

" ち～ん（笑）って鳴らさない
set visualbell
set t_vb=

" <Space>vsで縦分割、<Space>spで横分割
nnoremap <silent><Space>vs :<C-u>vsplit<CR>
nnoremap <silent><Space>sp :<C-u>sp<CR>

" バッファを選択する際に、同時にリストを表示する
" http://qiita.com/s_of_p/items/a80020cf32f3de5d044c
nnoremap <Leader>B :<C-u>ls<CR>:b

" JとgJを入れ替える
nnoremap J gJ
nnoremap gJ J

" 方向キーでバッファの大きさを変える
nnoremap <Right> <C-w>>
nnoremap <Left> <C-w><
nnoremap <Up> <C-w>+
nnoremap <Down> <C-w>-

" <BS>で行末やインサート開始前の文字列を消せられる
set backspace=indent,eol,start

" 挿入モード・コマンドラインモード時のカーソル移動
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" 矩形選択で自由に選択する
set virtualedit+=block

" クリップボード連携
if has('mac')
    set clipboard=unnamed
endif

" 全行ヤンク
command! PBcopy %y


" }}}
" ==================================================================
" プラグイン設定 {{{

" NeoBundleがある時だけ以下を読み込み
if glob('~/.vim/bundle/neobundle.vim') !=? ''

    " runtimepathを追加
    if has('vim_starting')
        set runtimepath+=~/.vim/bundle/neobundle.vim/
    endif

    " プラグイン読み込み開始
    " この関数は自動的にfiletype offを行う
    call neobundle#begin(expand('~/.vim/bundle/'))

    " NeoBundle自体
    NeoBundleFetch 'Shougo/neobundle.vim'

    " プラグイン
    NeoBundle 'itchyny/lightline.vim'
    NeoBundleLazy 'Shougo/vimshell.vim', {
                \ 'depends' : 'Shougo/vimproc',
                \ 'autoload' : {
                \   'commands' : [ 'VimShell', 'VimShellPop' ],
                \   'mappings' : '<Plug>(vimshell_'
                \   }
                \ }
    NeoBundle 'Shougo/vimproc', {
                \ 'build' : {
                \     'windows' : 'make -f make_mingw32.mak',
                \     'cygwin' : 'make -f make_cygwin.mak',
                \     'mac' : 'make -f make_mac.mak',
                \     'unix' : 'make -f make_unix.mak'
                \     }
                \ }
    NeoBundleLazy 'basyura/TweetVim', {
                \ 'depends' : [
                \     'tyru/open-browser.vim',
                \     'basyura/twibill.vim',
                \     'mattn/webapi-vim'
                \     ],
                \ 'autoload' : {
                \   'commands' : [ 'TweetVimUserStream', 'TweetVimSay' ]
                \   }
                \ }
    NeoBundleLazy 'thinca/vim-quickrun', {
                \ 'autoload' : {
                \   'mappings' : '<Leader>r',
                \   'commands' : 'QuickRun'
                \   }
                \ }
    NeoBundleLazy 'Shougo/unite.vim', {
                \ 'autoload' : {
                \   'commands' : 'Unite'
                \   }
                \ }
    NeoBundleLazy 'Shougo/neocomplete.vim', {
                \ 'autoload' : {
                \   'insert' : '1'
                \   }
                \ }
    NeoBundleLazy 'mattn/emmet-vim', {
                \ 'autoload' : {
                \   'filetypes' : [ 'html', 'markdown' ],
                \   }
                \ }
    NeoBundle 'tpope/vim-fugitive'
    NeoBundle 'Yggdroot/indentLine'
    NeoBundle 'haya14busa/incsearch.vim'
    NeoBundle 'thinca/vim-scouter'
    NeoBundle '844196/memo.vim', {
                \ 'depends' : 'Shougo/unite.vim'
                \ }
    NeoBundle 'gist:844196/4c1dc9a89dd02ece4ebe', {
                \ 'name' : 'Img_to_markdown.vim',
                \ 'script_type' : 'plugin'
                \ }
    NeoBundleDisable 'boucherm/ShowMotion'
    NeoBundle 'osyo-manga/vim-over'
    NeoBundle 'osyo-manga/vim-anzu'
    NeoBundle 'osyo-manga/vim-watchdogs', {
                \   'depends': [
                \       'osyo-manga/shabadou.vim',
                \       'Shougo/vimproc',
                \       'thinca/vim-quickrun',
                \       'cohama/vim-hier',
                \       'dannyob/quickfixstatus',
                \   ]
                \ }
    NeoBundle 'KazuakiM/vim-qfsigns', {
                \  'depends': 'osyo-manga/vim-watchdogs'
                \ }
    NeoBundle 'KazuakiM/vim-qfstatusline', {
                \  'depends': 'osyo-manga/vim-watchdogs'
                \ }
    NeoBundle 'osyo-manga/unite-quickfix', {
                \   'depends': 'Shougo/unite.vim'
                \ }
    NeoBundle 'osyo-manga/vim-sound'
    NeoBundle 'itchyny/vim-autoft'

    " カラースキーム
    NeoBundle 'altercation/vim-colors-solarized'
    NeoBundle 'w0ng/vim-hybrid'
    NeoBundle 'cocopon/lightline-hybrid.vim', {
                \ 'depends' : [
                \       'itchyny/lightline.vim',
                \       'w0ng/vim-hybrid'
                \       ]
                \ }
    NeoBundle 'ujihisa/unite-colorscheme', {
                \ 'depends' : 'Shougo/unite.vim'
                \ }
    NeoBundle 'tomasr/molokai'
    NeoBundle 'morhetz/gruvbox'
    NeoBundle 'sjl/badwolf'
    NeoBundle 'cocopon/colorswatch.vim'
    NeoBundle '844196/lightline-badwolf.vim', {
                \ 'depends' : [
                \       'itchyny/lightline.vim',
                \       'sjl/badwolf'
                \       ]
                \ }
    NeoBundle 'chriskempson/base16-vim'
    NeoBundle 'shinchu/lightline-gruvbox.vim', {
                \   'depends': [
                \       'itchyny/lightline.vim',
                \       'morhetz/gruvbox'
                \       ]
                \ }

    " プラグイン読み込み終了
    call neobundle#end()

    " よく分かんなかったです（無知）
    filetype plugin indent on

    " 未導入プラグインチェック
    NeoBundleCheck


    " 各プラグイン用リッチシンボル設定
    function! s:rich_unicode_symbols()
        if exists('g:rich_symbols') && g:rich_symbols =~# '1\|true\|rich\|fancy'
            let g:rich_unicode_symbol = {
                        \ 'Branch'    : "\u2b60",
                        \ 'LineColumn': "\u2b61",
                        \ 'FileType'  : "\u2b62\u2b63",
                        \ 'ReadOnly'  : "\u2b64"
                        \ }
            let g:lightline.separator = {
                        \ 'left' : "\u2b80",
                        \ 'right': "\u2b82"
                        \ }
            let g:lightline.subseparator = {
                        \ 'left' : "\u2b81",
                        \ 'right': "\u2b83"
                        \ }
        else
            let g:rich_unicode_symbol = {
                        \ 'Branch'    : '',
                        \ 'LineColumn': '',
                        \ 'FileType'  : '',
                        \ 'ReadOnly'  : 'RO'
                        \ }
            let g:lightline.separator = {
                        \ 'left' : '',
                        \ 'right': ''
                        \ }
            let g:lightline.subseparator = {
                        \ 'left' : '|',
                        \ 'right': '|'
                        \ }
        endif
    endfunction
    autocmd MyAutoCmd ColorScheme * call s:rich_unicode_symbols()
    autocmd MyAutoCmd BufWritePost $MYVIMRC,~/.vimrc_local call s:rich_unicode_symbols()

    " lightline.vim {{{
    if neobundle#tap('lightline.vim')
        let g:lightline = {}
        let g:lightline.component_function = {}
        let g:lightline = {
            \ 'component' : {
            \   'readonly' : '%{ &readonly ? g:rich_unicode_symbol.ReadOnly : "" }',
            \   'lineinfo' : '%{ winwidth(0) > 70 ? g:rich_unicode_symbol.LineColumn . " " . line(".") . ":" . col(".") : " " }',
            \   'fileformat' : '%{ winwidth(0) > 70 ? &fileformat : "" }',
            \   'fileencoding' : '%{ winwidth(0) > 70 ? strlen(&fenc)?&fenc:&enc : "" }',
            \   'filetype' : '%{ winwidth(0) > 70 ? strlen(&filetype)?g:rich_unicode_symbol.FileType ." ".&filetype:"no ft" : "" }'
            \   },
            \ 'component_function' : {
            \   'fugitive' : 'LightlineFugitive',
            \   'filename' : 'MyFilename',
            \   'mode'     : 'Mymode',
            \   'anzu'     : 'anzu#search_status'
            \   },
            \ 'component_expand' : {
            \   'qfstatusline': 'qfstatusline#Update'
            \   },
            \ 'component_type' : {
            \   'qfstatusline': 'error'
            \   },
            \ 'active' : {
            \   'left' : [ ['mode', 'paste'], ['readonly', 'fugitive', 'filename', 'modified'] ],
            \   'right': [ ['qfstatusline', 'anzu', 'lineinfo'], ['filetype'], ['fileformat', 'fileencoding'] ]
            \   },
            \ 'inactive' : {
            \   'right' : [ ['lineinfo'], ['filetype'] ]
            \   }
            \ }

        " Gitブランチを表示
        let g:lightline.component_function.fugitive = 'LightlineFugitive'
        function! LightlineFugitive()
            if exists('*fugitive#head')
                let s:_ = fugitive#head()
                return strlen(s:_) ? g:rich_unicode_symbol.Branch .' '.s:_ : ''
            endif
            return ''
        endfunction

        " カレントバッファのタイトル
        function! MyFilename()
            let s:fname = expand('%:~')
            return &ft ==# 'vimshell' ? vimshell#get_status_string() :
            \ &ft ==# 'unite' ? unite#get_status_string() :
            \ ('' !=? s:fname ? s:fname : '[No Name]')
        endfunction

        " lightline入れてるからモードを表示させない
        set noshowmode

        " UniteとかVimshellでもlightlineのステータスラインを表示
        let g:unite_force_overwrite_statusline=0
        let g:vimshell_force_overwrite_statusline=0

        " プラグイン別のモード表示
        function! Mymode()
            return &ft ==# 'unite' ? 'Unite' :
            \ &ft ==# 'vimshell' ? 'VimShell' :
            \ &ft ==# 'tweetvim' ? 'TweetVim' :
            \ lightline#mode()
        endfunction

        " リロード
        augroup LightLineColorscheme
            autocmd!
            autocmd ColorScheme * call s:lightline_update()
        augroup END
        function! s:lightline_update()
            if !exists('g:loaded_lightline')
                return
            endif
            try
                if g:colors_name =~# 'wombat\|solarized\|landscape\|jellybeans\|Tomorrow\|badwolf\|gruvbox'
                  let g:lightline.colorscheme =
                        \ substitute(substitute(g:colors_name, '-', '_', 'g'), '256.*', '', '') .
                        \ (g:colors_name ==# 'solarized' ? '_' . &background : '')
                  call lightline#init()
                  call lightline#colorscheme()
                  call lightline#update()
                endif
                catch
            endtry
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " TweetVim {{{
    if neobundle#tap('TweetVim')
        let g:tweetvim_config_dir = expand($HOME.'/.vim/tweetvim')

        " <Space>tsでツイートバッファを表示
        nnoremap <Space>ts :<C-u>TweetVimSay<CR>

        " <Space>thでタイムラインを表示
        nnoremap <Space>th :<C-u>TweetVimUserStream<CR>

        " 空文字セパレートを表示
        let g:tweetvim_display_separator = 1
        let g:tweetvim_empty_separator = 1

        " スクリーンネームを表示
        let g:tweetvim_display_username = 1

        " アイコンを表示
        if has('gui_running') || has('mac')
            "  1.環境設定→詳細→`Core Textレンダラを使用する`をオフにしてMacVim.appを終了させる
            "  2.MacVim.appを開きなおして、`Core Text〜`をオンにしてもっかい終了
            "  3.最後に開き直すと表示される。
            let g:tweetvim_display_icon = 1
        endif

        call neobundle#untap()
    endif
    " }}}

    " VimSell {{{
    if neobundle#tap('vimshell.vim')
        let g:vimshell_vimshrc_path = '~/dotfiles/.vimshrc'

        " <Leader>sでVimShellを開く
        nnoremap <silent><Leader>s :<C-u>VimShell<CR>

        " <C-g>でVimShell(Pop)を開く
        nnoremap <silent><C-g> :<C-u>VimShellPop -toggle<CR>
        inoremap <silent><C-g> <ESC>:<C-u>VimShellPop -toggle<CR>

        " X | _ | X
        let g:vimshell_prompt_expr = '"X | _ | X ".escape(getcwd(), "\\[]()?! ")." $ "'
        let g:vimshell_prompt_pattern = '^X\ |\ _\ |\ X\ \(\f\|\\.\)\+ $ '
        highlight vimshellPrompt ctermfg=yellow guifg=orange

        " 右プロンプトにGitブランチを表示
        let g:vimshell_right_prompt='Git_branch()'
        function! Git_branch()
            let s:branch = substitute(system('git rev-parse --abbrev-ref HEAD 2> /dev/null'), '\n', '', 'g')
            if s:branch ==? ''
                return ''
            else
                return '[' . g:rich_unicode_symbol.Branch . s:branch . ']'
            endif
        endfunction

        autocmd! MyAutoCmd FileType vimshell call s:vimshell_my_settings()
        function! s:vimshell_my_settings()
            " 行番号を表示しない
            setlocal nonumber

            " <C-l>で画面クリア
            imap <buffer><C-l> <Plug>(vimshell_clear)

            " どの行にいても最終行のプロンプトへフォーカスを移す
            nmap <buffer>I G<Plug>(vimshell_insert_head)
            nmap <buffer>A G<Plug>(vimshell_append_end)

        endfunction

        " VimShellからGitを使いやすくする
        if has('gui_macvim')
            " $EDITORをMacVimに設定
            " commit messageとかが出来るようになる
            let g:vimshell_editor_command = '/Applications/MacVim.app/Contents/MacOS/Vim --servername=VIM --remote-tab-wait-silent'

            " :bdしないとVimShellからの出てきたバッファの内容をVimShellへ反映できない
            " :w -> :bd はめんどいので、:wqを:w | bdへ置き換える（gitcommitファイル限定）
            autocmd MyAutoCmd FileType gitcommit cnoreabbrev <buffer><expr> wq 'WQ'
            autocmd MyAutoCmd FileType gitcommit command! -nargs=? -complete=dir -bang -buffer WQ call s:replace_wq_to_wbd('<bang>')

            function! s:replace_wq_to_wbd(bang)
                if a:bang ==? ''
                    write
                    bd
                else
                    write!
                    bd!
                endif
            endfunction

        endif

        call neobundle#untap()
    endif
    " }}}

    " vim-quickrun {{{
    if neobundle#tap('vim-quickrun')
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
                    \       "args"      : 'Marked\ 2',
                    \       "exec"      : "%c %o %a %s",
                    \   },
                    \ }

        " <C-c>でquickrun停止
        nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"

        call neobundle#untap()
    endif
    " }}}

    " Unite {{{
    if neobundle#tap('unite.vim')
        " バッファ一覧をUniteに置き換え
        nnoremap <Leader>b :<C-u>Unite<Space>buffer<CR>

        " <Leader><Leader>でUnite file
        nnoremap <Leader><Leader> :<C-u>Unite file<CR>

        " インサートモードオン
        let g:unite_enable_start_insert = 1

        " <Esc><Esc>でUniteを閉じる
        autocmd MyAutoCmd FileType unite call s:unite_my_settings()
        function! s:unite_my_settings()
            nmap <silent><buffer><Esc><Esc> <Plug>(unite_exit)
            imap <silent><buffer><Esc><Esc> <Plug>(unite_exit)
        endfunction

        call neobundle#untap()
    endif
    " }}}

    " memo.vim {{{
    if neobundle#tap('memo.vim')
        " メモディレクトリを宣言
        let g:memopath = '~/Dropbox/Memo/'

        " メモ一覧呼び出しリマップ
        nnoremap <silent><F2> :<C-u>Unite memo
                    \ -buffer-name=memo_list -winheight=10 -max-multi-lines=1
                    \ <CR>

        " メモGrep呼び出しリマップ
        nnoremap <silent><C-n> :<C-u>execute(
                    \ 'Unite grep:' . memo#getpath() . ' -no-empty -winheight=10'
                    \ )<CR>

        call neobundle#untap()
    endif
    " }}}

    " Img_to_markdown.vim {{{
    if neobundle#tap('Img_to_markdown.vim')
        " <Space>imで置換
        nmap <silent><Space>im <Plug>(img_to_markdown)

        call neobundle#untap()
    endif
    " }}}

    " neocomplete {{{
    if neobundle#tap('neocomplete.vim')
        " Vim起動時から補完スタート
        let g:neocomplete#enable_at_startup = 1

        " <F4>で補完切り替え
        nnoremap <F4> :<C-u>NeoCompleteToggle<CR>

        call neobundle#untap()
    endif
    " }}}

    " emmet-vim {{{
    if neobundle#tap('emmet-vim')
        let g:user_emmet_settings = {
                \ 'lang' : 'ja',
                \   'html': {
                \     'indentation': '  '
                \   }
                \ }

        call neobundle#untap()
    endif
    " }}}

    " indentLine
    if neobundle#tap('indentLine')
        " <F5>でガイドの表示切り替え
        nnoremap <silent><F5> :<C-u>IndentLinesToggle<CR>

        " インデントの色を変更（ターミナル）
        let g:indentLine_color_term = 239

        " インデントを1レベルから表示
        let g:indentLine_showFirstIndentLevel = 1

        call neobundle#untap()
    endif

    if neobundle#tap('incsearch.vim')
        " リマップ
        map / <Plug>(incsearch-forward)
        map ? <Plug>(incsearch-backward)
        map n <Plug>(incsearch-nohl-n)
        map N <Plug>(incsearch-nohl-N)

        call neobundle#untap()
    endif

    if neobundle#tap('ShowMotion')
        " リマップ
        nmap w <Plug>(show-motion-w)
        nmap W <Plug>(show-motion-W)
        nmap b <Plug>(show-motion-b)
        nmap B <Plug>(show-motion-B)
        nmap e <Plug>(show-motion-e)
        nmap E <Plug>(show-motion-E)

        call neobundle#untap()
    endif

    if neobundle#tap('vim-over')
        " プロンプト
        let g:over_command_line_prompt = '[over]:'
        " 置換したらハイライトを消す
        let g:over_enable_auto_nohlsearch = 1

        " リマップ
        map <silent><Space>s/ :OverCommandLine s/<CR>
        map <silent><Space>%s/ :OverCommandLine %s/<CR>

        call neobundle#untap()
    endif

    if neobundle#tap('vim-anzu')
        " incsearchと共存させる
        nmap n <Plug>(incsearch-nohl)<Plug>(anzu-n)
        nmap N <Plug>(incsearch-nohl)<Plug>(anzu-N)

        " <ESC><ESC>でステータスを消す
        nmap <silent><Esc><Esc> :<C-u>nohlsearch<CR><Plug>(anzu-clear-search-status)

        call neobundle#untap()
    endif

    if neobundle#tap('vim-watchdogs')
        " quickfixの窓を表示しない
        " 問題無かったらその旨表示する
        call extend(g:quickrun_config, {
                    \   "watchdogs_checker/_": {
                    \       "outputter/quickfix/open_cmd": "",
                    \       "hook/echo/enable": 1,
                    \       "hook/echo/output_success": "[watchdogs] No Errors Found."
                    \   }
                    \ })

        " 保存時にシンタックスチェック
        let g:watchdogs_check_BufWritePost_enable = 1

        " 一定周期でシンタックスチェック
        let g:watchdogs_check_CursorHold_enable = 1

        " vimは（あれば）vintでシンタックスチェック
        call extend(g:quickrun_config, {
                    \   "watchdogs_checker/vint": {
                    \       "command": "vint",
                    \       "exec": "%c %o %s:p "
                    \   },
                    \   "vim/watchdogs_checker": {
                    \       "type": executable("vint") ? "watchdogs_checker/vint" : ""
                    \   }
                    \ })

        " shとzshは（あれば）shellcheckでシンタックスチェック
        call extend(g:quickrun_config, {
                    \   "watchdogs_checker/shellcheck": {
                    \       "command": "shellcheck",
                    \       "cmdopt": "-f\ gcc",
                    \       "exec": "%c %o %s:p ",
                    \       "errorformat": "%f:%l:%c: %m"
                    \   },
                    \   "sh/watchdogs_checker": {
                    \       "type": executable("shellcheck") ? "watchdogs_checker/shellcheck" : ""
                    \   },
                    \   "zsh/watchdogs_checker": {
                    \       "type": executable("shellcheck") ? "watchdogs_checker/shellcheck" : ""
                    \   }
                    \ })

        call neobundle#untap()
    endif

    if neobundle#tap('vim-qfsigns')
        call extend(g:quickrun_config['watchdogs_checker/_'], {
                    \ "hook/qfsigns_update/enable_exit": 1,
                    \ "hook/qfsigns_update/priority_exit": 3
                    \ })

        call neobundle#untap()
    endif

    if neobundle#tap('vim-qfstatusline')
        call extend(g:quickrun_config['watchdogs_checker/_'], {
                    \ "hook/qfstatusline_update/enable_exit": 1,
                    \ "hook/qfstatusline_update/priority_exit": 3
                    \ })
        let g:Qfstatusline#UpdateCmd = function('lightline#update')

        " エラーメッセージを表示しない
        let g:Qfstatusline#Text = 0

        call neobundle#untap()
    endif

    if neobundle#tap('unite-quickfix')
        " <Leader>qでquickfixを表示
        nnoremap <silent><Leader>q :<C-u>Unite quickfix
                    \ -no-empty -direction=botright -no-start-insert
                    \ <CR>

        call neobundle#untap()
    endif

    if neobundle#tap('vim-sound')
        function! s:change_sound_name(basename)
            return expand(s:se_path . a:basename . s:se_ext)
        endfunction

        function! PlaySE(name)
            call sound#play_wav(s:change_sound_name(a:name))
        endfunction

        " ディレクトリがある時だけ効果音を設定
        let s:se_path = '~/Dropbox/soundeffect/'
        let s:se_ext = '.wav'
        if isdirectory(expand(s:se_path))
            augroup SoundEffect
                autocmd!
            augroup END

            autocmd SoundEffect BufReadPost  * call PlaySE("open")
            autocmd SoundEffect BufWritePost * call PlaySE("save")
            autocmd SoundEffect BufLeave     * call PlaySE("move")
            autocmd SoundEffect CompleteDone * call PlaySE("complete_done")
        endif

        call neobundle#untap()
    endif

    if neobundle#tap('vim-autoft')
        let g:autoft_config = [
                    \   { 'filetype': 'sh', 'pattern': '\%^#!.*\%(\<sh\>\|\<bash\>\)\s*$' },
                    \   { 'filetype': 'markdown', 'pattern': '^## .*$' }
                    \ ]

        call neobundle#untap()
    endif


endif

" }}}
" ==================================================================
" vimrc_local設定 {{{

" vimrc_localがあったら読み込む
if filereadable(expand($HOME.'/.vim/.vimrc_local'))
    source $HOME/.vim/.vimrc_local

    " <Space>elで.vimrc_localを編集
    nnoremap <Space>el :<C-u>edit $HOME/.vim/.vimrc_local<CR>

    " .vimrc、.vimrc_localを編集したら自動再読み込み
    autocmd MyAutoCmd BufWritePost $MYVIMRC nested source $HOME/.vim/.vimrc_local
    autocmd MyAutoCmd BufWritePost $HOME/.vim/.vimrc_local nested source $HOME/.vim/.vimrc_local
endif


" }}}
" ==================================================================
" 最終処理 {{{

" シンタックス有効
syntax on


" }}}
" ==================================================================
" vim: foldmethod=marker
