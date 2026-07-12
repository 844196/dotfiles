vim.opt.fileencodings = {
  -- BOMの検出を最優先にしないと、BOM付きUTF-8ファイルが正しく認識されない
  'ucs-bom',

  -- Default
  'utf-8',

  -- Shift JIS (iconv required)
  'shift-jis',
  'sjis',
  'cp932',
  'iso-2022-jp',

  -- System locale
  'default',

  -- 8ビットエンコーディングは一番最後に指定しなければならない
  'latin1',
}

-- 2 spaces indent (global)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0 -- i.e. Use tabstop value
vim.opt.expandtab = true

-- 邪魔
vim.opt.laststatus = 0
vim.opt.cmdheight = 0

-- ウィンドウ分割で開かれる新しいウィンドウは下もしくは右に表示させる
vim.opt.splitbelow = true
vim.opt.splitright = true

-- コマンドライン補完で大文字小文字を区別しない
vim.opt.wildignorecase = true

-- n/Nで移動時に最後のマッチに到達しても、最初のマッチへ戻らないように
vim.opt.wrapscan = false

-- 検索で大文字小文字を区別しないが、大文字を含む場合は区別する
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 挿入モードでの単語補完時に大文字小文字を区別しないが、大文字を含む場合は区別する ("vim.opt.ignorecase=true" required)
vim.opt.infercase = true

vim.opt.clipboard:append('unnamedplus')

-- コピー・ペーストの両方に win32yank を介すと遅い
if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'Copy to OSC 52, paste from win32yank.',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = true,
  }
end

-- 忘れられないの
vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_var('maplocalleader', ',')

vim.keymap.set('n', '<Leader>wh', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<Leader>wj', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<Leader>wk', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<Leader>wl', '<C-w>l', { noremap = true })
vim.keymap.set('n', '<Leader>wH', '<C-w>H', { noremap = true })
vim.keymap.set('n', '<Leader>wJ', '<C-w>J', { noremap = true })
vim.keymap.set('n', '<Leader>wK', '<C-w>K', { noremap = true })
vim.keymap.set('n', '<Leader>wL', '<C-w>L', { noremap = true })
vim.keymap.set('n', '<Leader>w=', '<C-w>=', { noremap = true })
vim.keymap.set('n', '<Leader>wv', '<C-w>v', { noremap = true })
vim.keymap.set('n', '<Leader>ws', '<C-w>s', { noremap = true })
vim.keymap.set('n', '<Leader>wt', '<Cmd>tabnew<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>wd', '<Cmd>silent! tabclose<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>wD', '<Cmd>silent tabonly<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>wx', '<Cmd>silent %bd<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>bs', '<Cmd>enew<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>bNh', '<Cmd>leftabove vnew<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>bNj', '<Cmd>belowright new<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>bNk', '<Cmd>aboveleft new<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>bNl', '<Cmd>belowright vnew<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>bd', '<C-w>c', { noremap = true })
vim.keymap.set('n', '<Leader>bD', '<C-w>o', { noremap = true })
vim.keymap.set('n', '<Leader>tn', '<Cmd>setlocal number!<CR>', { noremap = true })

-- 忘れられないの
vim.keymap.set('n', '<C-s>', '<Cmd>w<CR>', { noremap = true, silent = true })

-- 忘れられないの
-- https://apple.stackexchange.com/questions/24261/how-do-i-send-c-that-is-control-slash-to-the-terminal
-- https://www.reddit.com/r/neovim/comments/1hvxlq8/comment/m5wvsnf/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true })
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true })
vim.keymap.set('v', '<C-/>', 'gc', { remap = true })
vim.keymap.set('v', '<C-_>', 'gc', { remap = true })

-- https://vimrc-dissection.blogspot.com/2009/02/fixing-pageup-and-pagedown.html
vim.keymap.set({ 'n', 'v' }, '<PageUp>', '1000<C-u>zz')
vim.keymap.set({ 'n', 'v' }, '<PageDown>', '1000<C-d>zz')

-- Escでマッチハイライトを消す
vim.keymap.set('n', '<Esc>', '<Cmd>nohl<CR>', { noremap = true })

-- "E385: search hit TOP/BOTTOM without match for: xxx" が鬱陶しい
local movematch = function(k)
  return function()
    local ok = pcall(function()
      vim.cmd('norm! ' .. k)
    end)
    if ok then
      vim.cmd('norm! zz')
    end
  end
end
vim.keymap.set('n', 'n', movematch('n'), { noremap = true })
vim.keymap.set('n', 'N', movematch('N'), { noremap = true })

-- *で最初のマッチへ移動しないように
vim.keymap.set('n', '*', '"zyiw:let @/ = @z<CR>:<C-u>set hlsearch<CR>', { noremap = true })
vim.keymap.set('v', '*', '"zy:let @/ = @z<CR>:<C-u>set hlsearch<CR>', { noremap = true })

-- x/cで削除・選択した書き換え前テキストは削除レジスタへ送り、ヤンクレジスタを汚染しないように
vim.keymap.set({ 'n', 'v' }, 'x', '"_x', { noremap = true })
vim.keymap.set({ 'n', 'v' }, 'c', '"_c', { noremap = true })

-- 範囲選択中の貼り付け時に、ヤンクレジスタを汚染しないように
vim.keymap.set('v', 'p', 'P', { noremap = true })

-- ノーマルモードのまま現在行の上下に空行を挿入できるように
vim.keymap.set('n', '<CR>', 'o<Esc>', { noremap = true })
vim.keymap.set('n', '<S-CR>', 'O<Esc>', { noremap = true })

-- 矢印キーでの移動もドットリピートに含める
vim.keymap.set('i', '<Left>', '<C-g>U<Left>', { noremap = true })
vim.keymap.set('i', '<Right>', '<C-g>U<Right>', { noremap = true })
vim.keymap.set('i', '<Up>', '<C-g>U<Up>', { noremap = true })
vim.keymap.set('i', '<Down>', '<C-g>U<Down>', { noremap = true })

-- 改行文字を除く行末を選択しやすくする
vim.keymap.set('v', 'v', 'g_', { noremap = true })

require('config.lazy')
