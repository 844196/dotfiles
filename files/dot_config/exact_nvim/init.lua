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

require('config.pack')

require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'lua_ls',
    'jsonls',
    'yamlls',
    'tombi',
    'ts_ls',
  },
})
require('lazydev').setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

require('tokyonight').setup({
  style = 'night',
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
  },
  on_colors = function(colors)
    -- 行番号の明るさを下げる
    colors.fg_gutter = require('tokyonight.util').blend_bg(colors.fg_gutter, 0.7)
  end,
  on_highlights = function(hl, colors)
    hl.SnacksIndent = {
      fg = require('tokyonight.util').blend_bg(colors.fg_gutter, 0.2),
    }
    hl.SnacksIndentScope = {
      fg = colors.fg_gutter,
    }
  end,
})

vim.cmd([[colorscheme tokyonight]])

-- 2 spaces indent (global)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0 -- i.e. Use tabstop value
vim.opt.expandtab = true

require('snacks').setup({
  indent = {
    enabled = true,
    animate = { enabled = false },
  },
})

-- 邪魔
vim.opt.laststatus = 0
vim.opt.cmdheight = 0

require('vim._core.ui2').enable({
  enable = true,
  msg = {
    targets = 'msg'
  }
})

require('incline').setup()

require('bufferline').setup({
  options = {
    mode = 'tabs',
    separator_style = 'slant',
  },
})

-- 鬱陶しいので普段は行番号のみハイライトさせる
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

local statuscol_builtin = require('statuscol.builtin')
require('statuscol').setup({
  segments = {
    {
      text = { ' ' },
    },
    {
      condition = { statuscol_builtin.not_empty, true },
      text = { statuscol_builtin.lnumfunc, ' ' },
    },
    {
      text = { ' ' },
    },
  },
})

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

require('mini.completion').setup({
  lsp_completion = {
    source_func = 'completefunc',
    process_items = function (items, base)
      return MiniCompletion.default_process_items(items, base, {
        kind_priority = { Text = -1, Keyword = -1, Snippet = -1 },
      })
    end,
  },
})
vim.o.complete = 'F' -- completefunc (i.e. mini.completion)
MiniIcons.tweak_lsp_kind()

require('mini.trailspace').setup()

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
require('which-key').setup({
  delay = 0,
  triggers = {
    { '<Leader>', mode = { 'n', 'v' } },
    { '<LocalLeader>', mode = { 'n', 'v' } },
  },
  plugins = {
    marks = false,
    registers = false,
    spelling = { enabled = false }
  },
})

vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_var('maplocalleader', ',')

vim.keymap.set({ 'n', 'v' }, '<Leader><Leader>', ':')
vim.keymap.set('n', '<Leader>h<Leader>', ':h ')
vim.keymap.set('n', '<Leader>qq', '<Cmd>qa<CR>')
vim.keymap.set('n', '<Leader>wh', '<C-w>h')
vim.keymap.set('n', '<Leader>wj', '<C-w>j')
vim.keymap.set('n', '<Leader>wk', '<C-w>k')
vim.keymap.set('n', '<Leader>wl', '<C-w>l')
vim.keymap.set('n', '<Leader>wH', '<C-w>H')
vim.keymap.set('n', '<Leader>wJ', '<C-w>J')
vim.keymap.set('n', '<Leader>wK', '<C-w>K')
vim.keymap.set('n', '<Leader>wL', '<C-w>L')
vim.keymap.set('n', '<Leader>w=', '<C-w>=')
vim.keymap.set('n', '<Leader>wm', '<Cmd>wincmd _ | wincmd |<CR>')
vim.keymap.set('n', '<Leader>wv', '<C-w>v')
vim.keymap.set('n', '<Leader>ws', '<C-w>s')
vim.keymap.set('n', '<Leader>wc', '<Cmd>tabnew<CR>')
vim.keymap.set('n', '<Leader>wd', '<Cmd>silent! tabclose<CR>')
vim.keymap.set('n', '<Leader>wD', '<Cmd>silent tabonly<CR>')
vim.keymap.set('n', '<Leader>wx', '<Cmd>silent %bd<CR>')
vim.keymap.set('n', '<Leader>bs', '<Cmd>enew<CR>')
vim.keymap.set('n', '<Leader>bNh', '<Cmd>leftabove vnew<CR>')
vim.keymap.set('n', '<Leader>bNj', '<Cmd>belowright new<CR>')
vim.keymap.set('n', '<Leader>bNk', '<Cmd>aboveleft new<CR>')
vim.keymap.set('n', '<Leader>bNl', '<Cmd>belowright vnew<CR>')
vim.keymap.set('n', '<Leader>bd', '<C-w>c')
vim.keymap.set('n', '<Leader>bD', '<C-w>o')
vim.keymap.set('n', '<Leader>tn', '<Cmd>setlocal number!<CR>')
vim.keymap.set('n', '<Leader>thh', function()
  vim.o.cursorlineopt = vim.o.cursorlineopt == 'number' and 'both' or 'number'
end)
vim.keymap.set('n', '<Leader>tf', function()
  vim.o.colorcolumn = vim.o.colorcolumn ~= '120' and '120' or ''
end)
vim.keymap.set('n', '<Leader>fl', ':<C-u>set ft=')
vim.keymap.set('n', '<Leader>fyn', '<Cmd>let @+ = expand("%:.")<CR>', { desc = 'Copy current file name with extension' })
vim.keymap.set('n', '<Leader>fyy', '<Cmd>let @+ = expand("%:p")<CR>', { desc = 'Copy current file absolute path' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyl', function()
  local from, to = vim.fn.line('v'), vim.fn.line('.')
  if vim.fn.mode() == 'V' and from ~= to then
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. math.min(from, to) .. '-' .. math.max(from, to))
  else
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. to)
  end
end, { desc = 'Copy current file absolute path with line number(s)' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyc', '<Cmd>let @+ = expand("%:p").":".line(".").":".col(".")<CR>', { desc = 'Copy current file absolute path with line and column number' })
vim.keymap.set('n', '<Leader>fyd', '<Cmd>let @+ = expand("%:p:h")<CR>', { desc = 'Copy current directory absolute path' })

require('mini.pairs').setup()

require('mini.move').setup({
  -- 忘れられないの
  mappings = {
    -- Normal mode
    line_left = '<M-Left>',
    line_right = '<M-Right>',
    line_up = '<M-Up>',
    line_down = '<M-Down>',

    -- Visual mode
    left = '<M-Left>',
    right = '<M-Right>',
    up = '<M-Up>',
    down = '<M-Down>',
  },
})

-- 忘れられないの
vim.keymap.set({ 'n', 'i' }, '<C-s>', '<Cmd>w<CR>')

-- 忘れられないの
-- https://apple.stackexchange.com/questions/24261/how-do-i-send-c-that-is-control-slash-to-the-terminal
-- https://www.reddit.com/r/neovim/comments/1hvxlq8/comment/m5wvsnf/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true })
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true })
vim.keymap.set('v', '<C-/>', 'gc', { remap = true })
vim.keymap.set('v', '<C-_>', 'gc', { remap = true })

-- LSP
vim.keymap.set('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'g.', '<Cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', '<F2>', '<Cmd>lua vim.lsp.buf.rename()<CR>')

-- https://vimrc-dissection.blogspot.com/2009/02/fixing-pageup-and-pagedown.html
vim.keymap.set({ 'n', 'v' }, '<PageUp>', '1000<C-u>zz')
vim.keymap.set({ 'n', 'v' }, '<PageDown>', '1000<C-d>zz')

-- Escでマッチハイライトを消す
vim.keymap.set('n', '<Esc>', '<Cmd>nohl<CR>')

vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- *で最初のマッチへ移動しないように
vim.keymap.set('n', '*', '"zyiw:let @/ = @z<CR>:<C-u>set hlsearch<CR>')
vim.keymap.set('v', '*', '"zy:let @/ = @z<CR>:<C-u>set hlsearch<CR>')

-- x/cで削除・選択した書き換え前テキストは削除レジスタへ送り、ヤンクレジスタを汚染しないように
vim.keymap.set({ 'n', 'v' }, 'x', '"_x')
vim.keymap.set({ 'n', 'v' }, 'c', '"_c')

-- 範囲選択中の貼り付け時に、ヤンクレジスタを汚染しないように
vim.keymap.set('v', 'p', 'P')

-- ノーマルモードのまま現在行の上下に空行を挿入できるように
vim.keymap.set('n', '<CR>', 'o<Esc>')
vim.keymap.set('n', '<S-CR>', 'O<Esc>')

-- 矢印キーでの移動もドットリピートに含める
vim.keymap.set('i', '<Left>', '<C-g>U<Left>')
vim.keymap.set('i', '<Right>', '<C-g>U<Right>')
vim.keymap.set('i', '<Up>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<C-g>U<Up>'
end, { expr = true })
vim.keymap.set('i', '<Down>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<C-g>U<Down>'
end, { expr = true })

-- fb
vim.keymap.set('i', '<C-f>', '<C-g>U<Right>')
vim.keymap.set('i', '<C-b>', '<C-g>U<Left>')

-- completion menu
vim.keymap.set('i', '<C-c>', function()
  return vim.fn.pumvisible() == 1 and '<C-e>' or '<C-c>'
end, { expr = true })
vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })
vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })
vim.keymap.set('i', '<CR>', function()
  return vim.fn.complete_info()['selected'] ~= -1 and '<C-y>' or require('mini.pairs').cr()
end, { expr = true })

-- https://neovim.io/doc/user/insert/#i_CTRL-G_U
-- https://golang.hateblo.jp/entry/2023/04/20/201352
local MyHome = function()
  local col = vim.fn.col('.')
  local indent = vim.fn.indent('.')
  if col == indent + 1 then
    return string.rep('<C-g>U<Left>', col - 1)
  elseif col <= indent then
    return string.rep('<C-g>U<Right>', indent + 1 - col)
  else
    return string.rep('<C-g>U<Left>', col - 1 - indent)
  end
end

local MyEnd = function()
  return string.rep('<C-g>U<Right>', vim.fn.col('$') - vim.fn.col('.'))
end

vim.keymap.set('i', '<Home>', MyHome, { expr = true })
vim.keymap.set('i', '<C-a>', MyHome, { expr = true })
vim.keymap.set('i', '<End>', MyEnd, { expr = true })
vim.keymap.set('i', '<C-e>', MyEnd, { expr = true })

-- Deletion
vim.keymap.set('i', '<C-k>', '<C-o>"_D')

-- 改行文字を除く行末を選択しやすくする
vim.keymap.set('v', 'v', 'g_')

local telescope_actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    file_ignore_patterns = {
      "%.git/",
    },
    layout_strategy = 'horizontal',
    layout_config = {
      prompt_position = 'top',
    },
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ['<M-s>'] = telescope_actions.select_horizontal,
        ['<M-v>'] = telescope_actions.select_vertical,
        ['<M-t>'] = telescope_actions.select_tab,
      },
      n = {
        ['<M-s>'] = telescope_actions.select_horizontal,
        ['<M-v>'] = telescope_actions.select_vertical,
        ['<M-t>'] = telescope_actions.select_tab,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
      no_ignore = true,
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
})

vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files)

require('oil').setup({
  view_options = {
    show_hidden = true
  },
  keymaps = {
    ['q'] = { 'actions.close', mode = 'n' },
    ['<C-s>'] = {
      function()
        vim.cmd.stopinsert()
        require('oil').save()
      end,
      mode = { 'n', 'i' },
    },
    ['<C-p>'] = {
      function()
        -- https://github.com/stevearc/oil.nvim/issues/282
        require('telescope.builtin').find_files()
      end,
      mode = 'n',
    },
    ['<M-p>'] = { 'actions.preview', mode = 'n' },
    ['<M-s>'] = { 'actions.select', mode = 'n', opts = { horizontal = true } },
    ['<M-v>'] = { 'actions.select', mode = 'n', opts = { vertical = true } },
    ['<M-t>'] = { 'actions.select', mode = 'n', opts = { tab = true } },
  }
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>")
vim.keymap.set("n", "_", "<CMD>Oil .<CR>")
