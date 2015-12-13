" Init
" ------------------------------------------------------------------------------
set encoding=utf-8
scriptencoding utf-8

if !1 | finish | endif
if !&compatible | set nocompatible | endif



" Basic
" ------------------------------------------------------------------------------
set noswapfile                        " スワップファイルを作成しない
set nobackup                          " バックアップを作成しない
set noundofile                        " undoファイルを作成しない
set backspace=indent,eol,start        " <BS>が削除する位置（インデント、行末、改行マタギ）
set list                              " 特殊文字を表示
set listchars=tab:>-,trail:-          " 特殊文字のキャラクタ
set virtualedit=block                 " 自由な矩形選択
set expandtab                         " <Tab>をスペースに展開
set tabstop=4 shiftwidth=4            " <Tab>スペース展開文字幅
set shiftround                        " インデントをshiftwidthに丸める
set smarttab                          " 自動インデント
set autoindent                        " 改行後の自動インデント
set breakindent                       " 折り返した行がインデントに沿う
set synmaxcol=300                     " 1行あたりのシンタックス有効文字数
set number                            " 行番号
set scrolloff=10                      " バッファスクロール時に上下10行を確保
set showmatch                         " 対応するカッコをハイライト
set matchtime=1                       " カッコ間移動時間
set display=lastline                  " 行が長くても表示
set splitright                        " 分割バッファを右に開く
set hidden                            " ファイルを保存しなくても新しいバッファを開く
set laststatus=2                      " ステータスラインを常に表示
set ruler                             " ステータスラインに現在行情報を表示
set showcmd                           " ステータスライン下に入力中コマンドを表示
set cmdheight=2                       " コマンドラインの高さ
set wildmenu                          " コマンドライン補完
set wildignorecase                    " コマンドライン補完を大文字・小文字無視
set incsearch                         " インクリメンタルサーチ
set hlsearch                          " マッチ文字列をハイライト
set nowrapscan                        " 最後まで検索したら、最初のマッチ文字列に移動しない
set ignorecase                        " 検索文字列で大文字・小文字を区別しない
set smartcase                         " 検索文字列で大文字が混在している場合は区別する
set modeline                          " モードラインを有効
set modelines=5                       " モードラインを上下5行まで検索
set infercase                         " 補完時に大文字・小文字を区別しない
set textwidth=0                       " 行あたりの最大文字数？を0に（formatoptions）



" Remap
" ------------------------------------------------------------------------------
nnoremap <Space> :
vnoremap <Space> :

" Yの挙動をC, Dと揃える
nnoremap Y y$

" 一文字削除は削除レジスタを使用
nnoremap x "_x
vnoremap x "_x

" comma
inoremap , ,<Space>

" かっこ
inoremap '' ''<Left>
inoremap "" ""<Left>
inoremap () ()<Left>
inoremap {} {}<Left>
inoremap [] []<Left>
inoremap <> <><Left>

" search
nnoremap <silent><Esc><Esc> :<C-u>nohlsearch<CR>
nnoremap n nzz
nnoremap N Nzz

" 挿入モード時のカーソル移動
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-k> <C-o>D

" visual mode
vnoremap v $h

" コマンドモード時のカーソル移動
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos()-2]<CR>

" ノーマルモード時に<CR>で改行
nnoremap <CR> o<esc>

" バッファ操作
nnoremap <silent><Space>vs :<C-u>vsp<CR>
nnoremap <silent><Space>sp :<C-u>sp<CR>
nnoremap <silent><Space>vn :<C-u>vnew<CR>
nnoremap <silent><Space>st :<C-u>tabnew<CR>
nnoremap <silent><Left> <C-w><
nnoremap <silent><Right> <C-w>>
nnoremap <silent><Up> <C-w>+
nnoremap <silent><Down> <C-w>-

" toggle relative line number and column highlight
nnoremap <silent><F3> :<C-u>setlocal relativenumber!<CR>
nnoremap <silent><F1> :<C-u><C-\>e'setlocal colorcolumn='.(&colorcolumn ? '' : '120')<CR><CR>
nnoremap <silent><leader>c :<C-u>setlocal cursorcolumn!<CR>

" help
nnoremap <C-h> :h<Space>

" echo file path
nnoremap <C-g> 1<C-g>

" <C-w>oを上書き
command! Big wincmd _ | wincmd |
nnoremap <silent><C-w>o :<C-u>Big<CR>



" File type
" ------------------------------------------------------------------------------
augroup my_filetype
    autocmd!
    autocmd FileType help nnoremap <silent><buffer>q :quit<CR>
    autocmd FileType html,css,less,scss,ruby setlocal tabstop=2 shiftwidth=2
    autocmd FileType html inoremap <buffer></ </<C-x><C-o>
    autocmd FileType markdown hi! def link markdownItalic Normal
    autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn} setlocal filetype=markdown
augroup END



" Statusline
" ------------------------------------------------------------------------------
set statusline =\ %F\ \|\ %{&modified?'+\ \|':&modifiable?'':'-\ \|'}
set statusline+=%=\|\ %{(&fenc!=''?&fenc:&enc).':'.&ff}\ \|\ %{&filetype!=''?&filetype:'no\ ft'}\ \|\ %l:%c\ 



" Other
" ------------------------------------------------------------------------------
" Use vsplit mode (?)
" http://qiita.com/kefir_/items/c725731d33de4d8fb096
if has("vim_starting") && !has('gui_running') && has('vertsplit')
    function! g:EnableVsplitMode()
        " enable origin mode and left/right margins
        let &t_CS = "y"
        let &t_ti = &t_ti . "\e[?6;69h"
        let &t_te = "\e[?6;69l\e[999H" . &t_te
        let &t_CV = "\e[%i%p1%d;%p2%ds"
        call writefile([ "\e[?6;69h" ], "/dev/tty", "a")
    endfunction

    " old vim does not ignore CPR
    map <special> <Esc>[3;9R <Nop>

    " new vim can't handle CPR with direct mapping
    " map <expr> ^[[3;3R g:EnableVsplitMode()
    set t_F9=[3;3R
    map <expr> <t_F9> g:EnableVsplitMode()
    let &t_RV .= "\e[?6;69h\e[1;3s\e[3;9H\e[6n\e[0;0s\e[?6;69l"
endif

" 管理者権限で書き込み
if executable('sudo') && executable('tee')
    cnoremap w!! %!sudo tee > /dev/null %
endif

" Vimスクリプトの行継続のインデント幅
let g:vim_indent_cont = 4

" 挿入モードのクソみたいな挙動を切る
augroup no_comment
    autocmd!
    autocmd BufEnter * setlocal fo-=r
    autocmd BufEnter * setlocal fo-=o
    autocmd BufEnter * setlocal fo-=c
    autocmd BufEnter * setlocal fo-=t
    autocmd BufEnter * setlocal fo-=q
augroup END

" 全てのマッピングを表示
command! -nargs=* -complete=mapping AllMaps map <args> | map! <args> | lamp <args>

" 現在行ハイライトをカレントバッファのみに適用
augroup highlight_cursorline_on_current_buffer
    autocmd!
    autocmd BufLeave,WinLeave * setlocal nocursorline
    autocmd BufEnter,WinEnter * setlocal cursorline
augroup END

" reload .vimrc (and .vimrc_local if file readable)
augroup load_vimrc
    autocmd!
    autocmd BufWritePost ~/.vimrc,~/.vim/.vimrc_local nested source ~/.vimrc
augroup END



" NeoBundle wrap functions
" ------------------------------------------------------------------------------
function! s:bundle_tap(bundle)
    return exists('*neobundle#tap') && neobundle#tap(a:bundle)
endfunction

function! s:bundle_end()
    try
        call neobundle#untap()
        call neobundle#end()
        filetype plugin indent on
        NeoBundleCheck
        if !has('vim_starting')
            call neobundle#call_hook('on_source')
        endif
    catch
    endtry
endfunction



" Load plugins list
" ------------------------------------------------------------------------------
if isdirectory(expand('~/.vim/bundle/neobundle.vim'))
    if has('vim_starting')
        set rtp+=~/.vim/bundle/neobundle.vim/
    endif
    call neobundle#begin(expand('~/.vim/bundle/'))

    NeoBundleFetch 'Shougo/neobundle.vim'

    " base
        NeoBundle     'Shougo/vimproc'
        NeoBundle     'vim-jp/vimdoc-ja'

    " looks
        NeoBundle     'ryanoasis/vim-devicons'
        NeoBundleLazy 'Yggdroot/indentLine'
        NeoBundle     'itchyny/lightline.vim'
        NeoBundle     'altercation/vim-colors-solarized'

    " util
        NeoBundle     'tomtom/tcomment_vim'
        NeoBundle     'tpope/vim-endwise'
        NeoBundleLazy 'haya14busa/incsearch.vim'
        NeoBundleLazy 'osyo-manga/vim-over'
        NeoBundle     'rhysd/clever-f.vim'
        NeoBundleLazy 'Shougo/unite.vim'
        NeoBundleLazy 'thinca/vim-scouter'
        NeoBundleLazy 'mattn/benchvimrc-vim'
        NeoBundleLazy 'scrooloose/nerdtree'
        NeoBundleLazy 'thinca/vim-quickrun'
        NeoBundleLazy 'haya14busa/vim-undoreplay'

    " completation
        NeoBundleLazy 'Shougo/neocomplete.vim'
        NeoBundleLazy 'ujihisa/neco-look'
        NeoBundleLazy 'Shougo/context_filetype.vim'
        NeoBundleLazy 'Shougo/neco-syntax'

    " for git
        NeoBundleLazy 'cohama/agit.vim'
        NeoBundleLazy 'rhysd/committia.vim'

    " for html
        NeoBundleLazy 'mattn/emmet-vim'
        NeoBundleLazy 'lilydjwg/colorizer'

    " for markdown
        NeoBundleLazy 'junegunn/goyo.vim'
        NeoBundleLazy 'kannokanno/previm'
        NeoBundleLazy 'rcmdnk/vim-markdown'
        NeoBundleLazy 'joker1007/vim-markdown-quote-syntax'

    " for ruby
        NeoBundleLazy 'noprompt/vim-yardoc'
        NeoBundleLazy 'sunaku/vim-ruby-minitest'
endif



" Plugins config
" ------------------------------------------------------------------------------
if s:bundle_tap('neobundle.vim')
    nnoremap <silent><space>nl :<C-u>NeoBundleList<CR>
endif

if s:bundle_tap('vimproc')
    " TODO: disabledが動いてない
    call neobundle#config({
        \   'build': {
        \       'windows': 'tools\\update-dll-mingw',
        \       'cygwin' : 'make -f make_cygwin.mak',
        \       'mac'    : 'make',
        \       'linux'  : 'make',
        \       'unix'   : 'gmake'
        \   }
        \ })
endif

if s:bundle_tap('lightline.vim')
    set noshowmode
    let g:lightline = {}

    " component
    let g:lightline.component = {
        \   'filename': '%{strlen(expand("%:~")) ? expand("%:~") : "[No Name]"}'
        \ }

    " display
    let g:lightline.active = {
        \   'left' : [['mode','paster'], ['readonly','filename','modified']],
        \   'right': [['lineinfo'], ['filetype'], ['fileencoding','fileformat']]
        \ }
    let g:lightline.inactive = {
        \   'right': [['lineinfo'], ['filetype']]
        \ }
endif

if s:bundle_tap('neocomplete.vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_i': 1,
        \   'disabled': !has('lua')
        \ })

    " ロード時から補完スタート
    let g:neocomplete#enable_at_startup = 1

    " <F4>で補完切り替え
    nnoremap <F4> :<C-u>NeoCompleteToggle<CR>

    let g:neocomplete#enable_ignore_case = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_enable_camel_case_completion = 1
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns._ = '\h\w*'
    let g:neocomplete#max_list = 20
endif

if s:bundle_tap('indentLine')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_cmd': 'IndentLinesToggle'
        \ })

    " <F5>でガイドの表示切り替え
    nnoremap <silent><F5> :<C-u>IndentLinesToggle<CR>

    " インデントの色を変更（ターミナル）
    let g:indentLine_color_term = 239

    " インデント表示文字列
    let g:indentLine_char = '¦'
endif

if s:bundle_tap('vim-quickrun')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {
        \     'mappings': '<Leader>r',
        \     'commands': 'QuickRun'
        \     }
        \ })

    let g:quickrun_config = {}
    let g:quickrun_config._ = {
        \   "outputter/buffer/split": ":botright 8sp",
        \   "outputter/buffer/close_on_empty": 1,
        \   "runner": "vimproc",
        \   "runner/vimproc/updatetime": 60
        \ }
    let g:quickrun_config.markdown ={
        \   "outputter": "null",
        \   "command"  : "open",
        \   "cmdopt"   : "-a",
        \   "args"     : 'Marked\ 2',
        \   "exec"     : "%c %o %a %s"
        \ }

    " <C-c>でquickrun停止
    nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"
endif

if s:bundle_tap('unite.vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'commands': 'Unite'}
        \ })

    " バッファ一覧をUniteに置き換え
    nnoremap <Leader>b :<C-u>Unite<Space>buffer<CR>

    " <Leader><Leader>でUnite file
    nnoremap <Leader><Leader> :<C-u>Unite file<CR>

    " インサートモードオン
    let g:unite_enable_start_insert = 1

    " <Esc><Esc>でUniteを閉じる
    augroup unite_my_settings
        autocmd!
        autocmd FileType unite call s:unite_my_settings()
    augroup END
    function! s:unite_my_settings()
        nmap <silent><buffer><Esc><Esc> <Plug>(unite_exit)
        imap <silent><buffer><Esc><Esc> <Plug>(unite_exit)
    endfunction

    " disable overwrite unite statusline
    if neobundle#is_installed('lightline.vim')
        let g:unite_force_overwrite_statusline=0
    endif
endif

if s:bundle_tap('incsearch.vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload' : {'mappings': '<Plug>(incsearch-'}
        \ })

    " リマップ
    map / <Plug>(incsearch-forward)
    map ? <Plug>(incsearch-backward)
    map n <Plug>(incsearch-nohl-n)zz
    map N <Plug>(incsearch-nohl-N)zz
endif

if s:bundle_tap('vim-over')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'commands': 'OverCommandLine'}
        \ })

    " プロンプト
    let g:over_command_line_prompt = '[over]:'
    " 置換したらハイライトを消す
    let g:over_enable_auto_nohlsearch = 1

    " リマップ
    nnoremap <silent><Space>s/ :OverCommandLine s/<CR>
    vnoremap <silent><Space>s/ :OverCommandLine s/<CR>
    nnoremap <silent><Space>%s/ :OverCommandLine %s/<CR>
endif

if s:bundle_tap('previm')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'commands': 'PrevimOpen'}
        \ })

    let g:previm_show_header = 0
endif

if s:bundle_tap('nerdtree')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_cmd': 'NERDTree'
        \ })

    nnoremap <silent><Leader>nt :<C-u>NERDTreeToggle<CR>
    nnoremap <C-n> :<C-u>NERDTree<Space>
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeMouseMode = 2
    let g:NERDTreeChDirMode = 1
endif

if s:bundle_tap('vim-devicons')
    let g:WebDevIconsUnicodeGlyphDoubleWidth = 1
    let g:WebDevIconsUnicodeDecorateFolderNodes = 1
    let g:webdevicons_enable_unite = 1

    " nerdtree
    if neobundle#is_installed('nerdtree')
        let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
        let g:NERDTreeDirArrowExpandable = "\uf105"
        let g:NERDTreeDirArrowCollapsible = "\uf107"
    endif

    " lightline icon
    if neobundle#is_installed('lightline.vim')
        call extend(g:lightline.component, {
            \   'readonly': '%{&readonly ? "\ue0a2" : ""}',
            \   'lineinfo': '%{"\ue0a1" . " " . line(".") . ":" . col(".")}',
            \   'filetype': '%{strlen(&filetype) ? WebDevIconsGetFileTypeSymbol()." ".&filetype : "no ft"}',
            \ })
        let g:lightline.separator = {
            \   'left' : "\ue0b0",
            \   'right': "\ue0b2"
            \ }
        let g:lightline.subseparator = {
            \   'left' : "\ue0b1",
            \   'right': "\ue0b3"
            \ }
    endif
endif

if s:bundle_tap('emmet-vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload' : {'filetypes': ['html', 'markdown', 'css', 'scss', 'less']}
        \ })

    let g:user_emmet_settings = {
        \ 'lang' : 'ja',
        \ 'html': {'indentation': '  '}
        \ }
endif

if s:bundle_tap('colorizer')
    call neobundle#config({
        \   'lazy': 1,
        \   'gui': 1,
        \   'autoload' : {'filetypes': ['html', 'markdown', 'css', 'scss', 'less']}
        \ })
endif

if s:bundle_tap('vim-scouter')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload' : {'commands': 'Scouter'}
        \ })
endif

if s:bundle_tap('goyo.vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'commands': 'Goyo'}
        \ })

    nnoremap <silent><leader>g :<C-u>Goyo<CR>
endif

if s:bundle_tap('vim-yardoc')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'filetypes': 'ruby'}
        \ })
endif

if s:bundle_tap('vim-ruby-minitest')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'filetypes': 'ruby'}
        \ })
endif

if s:bundle_tap('vim-markdown')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'filetypes': 'markdown'}
        \ })

    let g:vim_markdown_frontmatter = 1
    let g:vim_markdown_folding_disabled = 1
endif

if s:bundle_tap('vim-markdown-quote-syntax')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'filetypes': 'markdown'}
        \ })
endif

if s:bundle_tap('agit.vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'commands': 'Agit'}
        \ })
endif

if s:bundle_tap('committia.vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'autoload': {'filetypes': 'gitcommit'}
        \ })
endif

if s:bundle_tap('neco-look')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_source': 'neocomplete.vim'
        \ })
endif

if s:bundle_tap('context_filetype.vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_source': 'neocomplete.vim'
        \ })
endif

if s:bundle_tap('neco-syntax')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_source': 'neocomplete.vim'
        \ })
endif

if s:bundle_tap('vim-colors-solarized')
    if neobundle#is_installed('lightline.vim')
        let s:mono0   = ['#002B36', '8' ]
        let s:mono1   = ['#073642', '0' ]
        let s:mono2   = ['#586E75', '10']
        let s:mono3   = ['#657B83', '11']
        let s:mono4   = ['#839496', '12']
        let s:mono5   = ['#93A1A1', '14']
        let s:white0  = ['#EEE8D5', '7' ]
        let s:white1  = ['#FDF6E3', '15']
        let s:red     = ['#DC322F', '1' ]
        let s:green   = ['#859900', '2' ]
        let s:blue    = ['#268BD2', '4' ]
        let s:yellow  = ['#B58900', '3' ]
        let s:orange  = ['#CB4B16', '9' ]
        let s:magenta = ['#D33682', '5' ]
        let s:cyan    = ['#2AA198', '6' ]
        let s:purple  = ['#6C71C4', '13']

        let s:p = {'normal': {}, 'insert': {}, 'visual': {}, 'replace': {}, 'inactive': {}, 'tabline': {}}

        let s:p.normal.left     = [ [s:white1[0], s:blue[0], s:white1[1], s:blue[1]],
                                \   [s:white0[0], s:mono2[0], s:white0[1], s:mono2[1]],
                                \ ]

        let s:p.insert.left     = [ [s:white0[0], s:yellow[0], s:white0[1], s:yellow[1]],
                                \   [s:white0[0], s:mono2[0], s:white0[1], s:mono2[1]],
                                \ ]

        let s:p.visual.left     = [ [s:white1[0], s:magenta[0], s:white1[1], s:magenta[1]],
                                \   [s:white0[0], s:mono2[0], s:white0[1], s:mono2[1]],
                                \ ]

        let s:p.replace.left    = [ [s:white1[0], s:orange[0], s:white1[1], s:orange[1]],
                                \   [s:white0[0], s:mono2[0], s:white0[1], s:mono2[1]],
                                \ ]

        let s:p.normal.right    = [ [s:mono0[0], s:mono4[0], s:mono0[1], s:mono4[1]],
                                \   [s:mono1[0], s:mono3[0], s:mono1[1], s:mono3[1]],
                                \   [s:mono4[0], s:mono1[0], s:mono4[1], s:mono1[1]]
                                \ ]

        let s:p.inactive.middle = [ [s:mono4[0], s:mono1[0], s:mono4[1], s:mono1[1]],
                                \   [s:mono4[0], s:mono1[0], s:mono4[1], s:mono1[1]],
                                \   [s:mono4[0], s:mono1[0], s:mono4[1], s:mono1[1]],
                                \ ]
        let s:p.inactive.left   = s:p.inactive.middle
        let s:p.inactive.right  = s:p.inactive.middle

        let s:p.normal.middle   = [ [s:mono2[0], s:mono1[0], s:mono2[1], s:mono1[1]],
                                \   [s:mono2[0], s:mono1[0], s:mono2[1], s:mono1[1]],
                                \   [s:mono2[0], s:mono1[0], s:mono2[1], s:mono1[1]],
                                \ ]
        let s:p.inactive.left   = s:p.normal.middle
        let s:p.inactive.right  = s:p.normal.middle

        let s:p.tabline.middle  = [ [s:blue[0], s:mono1[0], s:blue[1], s:mono1[1]] ]
        let s:p.tabline.tabsel  = [ [s:white0[0], s:yellow[0], s:white0[1], s:yellow[1]] ]
        let s:p.tabline.left    = [ [s:mono5[0], s:mono2[0], s:mono5[1], s:mono2[1]] ]
        let s:p.tabline.right   = [ [s:mono5[0], s:mono0[0], s:mono5[1], s:mono0[1]] ]

        let lightline#colorscheme#modified_solarized#palette = s:p
        let g:lightline.colorscheme = 'modified_solarized'
    endif

    function! neobundle#hooks.on_source(bundle)
        set bg=dark
        colorscheme solarized
    endfunction
endif

if s:bundle_tap('vim-undoreplay')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_cmd': 'UndoReplay'
        \ })
endif

if s:bundle_tap('vimdoc-ja')
    set helplang=ja,en
endif

if s:bundle_tap('benchvimrc-vim')
    call neobundle#config({
        \   'lazy': 1,
        \   'on_cmd': 'BenchVimrc'
        \ })
endif



" Finish
" ------------------------------------------------------------------------------
" load .vimrc_local if file readable
if filereadable(expand('~/.vim/.vimrc_local'))
    source ~/.vim/.vimrc_local
endif

" end neobundle block
call s:bundle_end()

" enable syntax
syntax on
