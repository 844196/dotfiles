" 通常設定 {{{1

"モードラインを有効にする
set modeline

"モードライン3行目までを検索
set modelines=3

"新しい行のインデントを現在行と同じにする
set autoindent

"vi互換をオフする
set nocompatible

"スワップを作成しない
set noswapfile

"バックアップを作成しない
set nobackup

"タブの代わりに空白文字を指定する
set expandtab

"変更中のファイルでも、保存しないで他のファイルを表示する
set hidden

"インクリメンタルサーチを行う
set incsearch

"行番号を表示する
set number

"閉括弧が入力された時、対応する括弧を強調する
set showmatch

"新しい行を作った時に高度な自動インデントを行う
set smarttab

"カーソル位置をハイライト
set cursorline

"ヤンクしたテキストをクリップボードにコピー
set clipboard+=unnamed

"入力中のコマンドを下に表示
set showcmd

"ステータスラインを常に表示
set laststatus=2

"不可視文字を表示
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%

"insertモードを抜けるとIMEオフ
set noimdisable
set iminsert=0 imsearch=0
set noimcmdline
inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>

"最後まで検索したら最初にワープしない
set nowrapscan

"memo.mdを呼び出し
command! Memo edit ~/Dropbox/memo/memo.md

"Tabはスペース4つに変換 BackSpace押したらスペース4つ消せるよ
set tabstop=4
set shiftwidth=4

" リマップ {{{1

"ノーマルモードでEnterを押すと空行を挿入
noremap <CR> o<ESC>
noremap <S-CR> O<ESC>

";を:に置き換え
nnoremap ; :

"検索結果のハイライトをEsc連打でクリアする
nnoremap <ESC><ESC> :nohlsearch<CR>

"カッコ系を入力したら自動で中にカーソルを移動させる
imap {} {}<Left>
imap [] []<Left>
imap "" ""<Left>
imap '' ''<Left>
imap <> <><Left>
imap () ()<Left>

"カンマを打ったら自動でスペースを入れる
inoremap , ,<Space>

"insert modeでjjでnormal modeへ
inoremap jj <Esc>

"<space>evで.vimrcを編集, <space>egで.gvimrcを編集
nnoremap <silent> <Space>ev :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> <Space>eg :<C-u>edit $MYGVIMRC<CR>

".vimrcや.gvimrcを変更すると、自動的に変更が反映されるようにする
augroup MyAutoCmd
autocmd!
augroup END

if !has('gui_running') && !(has('win32') || has('win64'))

".vimrcの再読込時にも色が変化するようにする
autocmd MyAutoCmd BufWritePost $MYVIMRC nested source $MYVIMRC
else

".vimrcの再読込時にも色が変化するようにする
autocmd MyAutoCmd BufWritePost $MYVIMRC source $MYVIMRC |
\if has('gui_running') | source $MYGVIMRC
autocmd MyAutoCmd BufWritePost $MYGVIMRC if has('gui_running') | source $MYGVIMRC
endif
"" }}}
" NeoBundle {{{1
filetype off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'https://github.com/mattn/qiita-vim.git'
NeoBundle 'https://github.com/h1mesuke/unite-outline.git'

" Powerline {{{2
NeoBundle 'taichouchou2/alpaca_powertabline'
NeoBundle 'Lokaltog/powerline', { 'rtp' : 'powerline/bindings/vim'}

"TweetVim 前提 {{{2
NeoBundle 'https://github.com/basyura/bitly.vim.git'
NeoBundle 'https://github.com/basyura/TweetVim.git'
NeoBundle 'https://github.com/basyura/twibill.vim.git'
NeoBundle 'https://github.com/h1mesuke/unite-outline.git'
NeoBundle 'https://github.com/mattn/webapi-vim.git'
NeoBundle 'https://github.com/tyru/open-browser.vim.git'
NeoBundle 'https://github.com/yomi322/neco-tweetvim.git'
NeoBundle 'https://github.com/yomi322/unite-tweetvim.git'

"カラースキーム {{{2
NeoBundle 'vim-scripts/chlordane.vim'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'tomasr/molokai.git'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'https://github.com/therubymug/vim-pyte.git'

NeoBundle 'ujihisa/unite-colorscheme'
"<leader>+ucでunite-colorschemeを呼び出す
nnoremap <Leader>uc :<C-u>Unite colorscheme -auto-preview<CR>

"numbers.vim {{{2
NeoBundle 'https://github.com/myusuf3/numbers.vim.git'
nnoremap <F3> :NumbersToggle<CR>
" }}}2

filetype plugin indent on     " required!
filetype indent on
syntax on
" }}}1

" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: foldlevel=0
