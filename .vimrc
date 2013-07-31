" 通常設定 {{{1

"モードラインを有効にする
set modeline

"モードライン3行目までを検索
set modelines=3

"シンタックス有効
syntax on

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

"markdownファイルのシンタックス関連付け
autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown

" リマップ {{{1

"ノーマルモードでEnterを押すと空行を挿入
noremap <CR> o<ESC>
noremap <S-CR> O<ESC>

";を:に置き換え
nnoremap ; :

"F5でBGを変更
call togglebg#map('<F5>')

"カッコ系を入力したら自動で中にカーソルを移動させる
imap {} {}<Left>
imap [] []<Left>
imap "" ""<Left>
imap '' ''<Left>
imap <> <><Left>
imap () ()<Left>

"検索結果のハイライトをEsc連打でクリアする
nnoremap <ESC><ESC> :nohlsearch<CR>

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
"" }}}1

"プラグイン周りは別ファイルに移した
"~/.vimpluginがある場合はそっちも読み込む
if filereadable(expand('~/.vimplugin'))
    source ~/.vimplugin
endif


" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: foldlevel=0
