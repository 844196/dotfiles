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

-- 忘れられないの
vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_var('maplocalleader', ',')

-- 忘れられないの
vim.keymap.set('n', '<C-s>', '<Cmd>w<CR>', { noremap = true, silent = true })

-- 忘れられないの
-- https://apple.stackexchange.com/questions/24261/how-do-i-send-c-that-is-control-slash-to-the-terminal
-- https://www.reddit.com/r/neovim/comments/1hvxlq8/comment/m5wvsnf/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true })
vim.keymap.set('v', '<C-_>', 'gc', { remap = true })

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

-- ウィンドウごとに行番号の表示/非表示を切り替えられるように
vim.keymap.set('n', '<C-g>', '<Cmd>set number!<CR>', { noremap = true })

require('config.lazy')
