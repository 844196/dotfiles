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

vim.opt.tabstop = 2
vim.opt.shiftwidth = 0 -- i.e. Use tabstop value
vim.opt.expandtab = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.virtualedit:append('block')
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrapscan = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.infercase = true
vim.opt.wildignorecase = true
vim.opt.cmdheight = 0
vim.opt.wrap = false

vim.opt.clipboard:append('unnamedplus')
if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'Copy to OSC 52, paste from win32yank.',
    -- コピー・ペーストの両方に win32yank を介すと遅い
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

require('config.pack')

require('config.colorscheme')
require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require('config.treesitter')
require('config.lsp')

require('snacks').setup({
  indent = {
    enabled = true,
    animate = { enabled = false },
  },
  scroll = {
    animate = {
      duration = { total = 25 },
      easing = 'linear',
    },
    filter = function(buf)
      -- codediff.nvim は独自のスクロール同期 (scrollsync) で diff ウィンドウ間の表示位置を直接書き換えるため、スクロール位置がおかしくなる。
      -- diff ビューに属するウィンドウ (同一タブページの scrollsync グループのメンバー) ではアニメーションを無効化する。
      local ok, codediff_scroll = pcall(require, 'codediff.ui.scroll')
      if not ok then
        return true
      end
      local tabpage = vim.api.nvim_get_current_tabpage()
      local group = codediff_scroll.get(tabpage)
      if not group then
        return true
      end
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.api.nvim_win_get_tabpage(win) == tabpage then
          for _, member in ipairs(group.wins) do
            if member == win then
              return false
            end
          end
        end
      end
      return true
    end,
  },
})

require('vim._core.ui2').enable({
  enable = true,
  msg = {
    targets = 'msg'
  }
})

require('config.lualine')

require('config.number').setup({ initial_state = 'off' })
require('config.cursorline').setup({ initial_state = "number" })

require('gitsigns').setup({
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = "" },
    topdelete    = { text = "" },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = "" },
    topdelete    = { text = "" },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
})

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
      sign = { namespace = { 'gitsigns' }, maxwidth = 1, colwidth = 1, auto = true },
      click = 'v:lua.ScSa',
    },
    {
      text = { ' ' },
    },
  },
})

require('no-neck-pain').setup({
  width = 180,
  disableOnLastBuffer = true,
  killAllBuffersOnDisable = true,
})

require('blink.cmp').setup({
  keymap = {
    preset = 'default',
    ['<C-n>'] = { 'show', 'select_next', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
    ['<End>'] = {
      function(cmp)
        return cmp.hide({
          callback = function()
            vim.api.nvim_feedkeys(vim.keycode(require('config.keymap_actions').undoable_end()), 'n', false)
          end,
        })
      end,
      'fallback',
    },
    ['<C-e>'] = {
      function(cmp)
        return cmp.hide({
          callback = function()
            vim.api.nvim_feedkeys(vim.keycode(require('config.keymap_actions').undoable_end()), 'n', false)
          end,
        })
      end,
      'fallback',
    },
    ['<C-c>'] = { 'cancel', 'fallback' },
    ['<Esc>'] = {
      function(cmp)
        return cmp.hide({
          callback = function()
            vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'n', false)
          end,
        })
      end,
      'fallback',
    },
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    list = {
      selection = { preselect = true, auto_insert = false },
    },
    menu = {
      border = nil,
    },
    documentation = { auto_show = true },
  },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippets' },
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
  },
})

require('mini.trailspace').setup()

-- VS Codeのデフォルト (autoClosingBrackets) に合わせ、カーソル直後の文字が空白/行末
-- もしくは ;:.,=}])> のいずれか (バッククォート含む) のときだけ自動で閉じ括弧・閉じクォートを挿入する。
-- それ以外 (例: 単語の途中) では単一文字のみ挿入する
local AUTOCLOSE_BEFORE = '[%s;:,.=}%])>`]'
require('mini.pairs').setup({
  mappings = {
    ['('] = { neigh_pattern = '^[^\\]' .. AUTOCLOSE_BEFORE },
    ['['] = { neigh_pattern = '^[^\\]' .. AUTOCLOSE_BEFORE },
    ['{'] = { neigh_pattern = '^[^\\]' .. AUTOCLOSE_BEFORE },
    ['"'] = { neigh_pattern = '^[^\\]' .. AUTOCLOSE_BEFORE },
    ["'"] = { neigh_pattern = '^[^%a\\]' .. AUTOCLOSE_BEFORE },
    ['`'] = { neigh_pattern = '^[^\\]' .. AUTOCLOSE_BEFORE },
  },
})

require('mini.move').setup({
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

local keymap_actions = require('config.keymap_actions')

vim.keymap.set('n', '<Esc>', '<Cmd>nohl<CR>')
vim.keymap.set('n', '<CR>', function()
  -- quickfix リスト内で選択できるように
  return vim.bo.modifiable and 'o<Esc>' or '<CR>'
end, { expr = true })
vim.keymap.set('n', '<S-CR>', 'O<Esc>')
vim.keymap.set('n', '/', [[/\v]])
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set({ 'n', 'i', 'x' }, '<C-l>', keymap_actions.recenter)
vim.keymap.set({ 'n', 'x' }, 'M', keymap_actions.recenter_cursor)
vim.keymap.set('n', '<M-;>',  'gcc', { remap = true })
vim.keymap.set('v', '<M-;>',  'gc', { remap = true })
vim.keymap.set('n', 'K', function() vim.lsp.buf.hover({ border = 'rounded' }) end)
vim.keymap.set({ 'n', 'x' }, 'gf', 'gF')
vim.keymap.set({ 'n', 'x' }, 'gx', keymap_actions.open)

-- https://vimrc-dissection.blogspot.com/2009/02/fixing-pageup-and-pagedown.html
-- https://github.com/folke/snacks.nvim/discussions/1030#discussioncomment-12109404
vim.keymap.set({ 'n', 'v' }, '<PageUp>', function()
  vim.wo.scrolloff = 1000
  vim.defer_fn(function() vim.wo.scrolloff = 4 end, 33)
  return '<C-u>'
end, { expr = true })
vim.keymap.set({ 'n', 'v' }, '<PageDown>', function()
  vim.wo.scrolloff = 1000
  vim.defer_fn(function() vim.wo.scrolloff = 4 end, 33)
  return '<C-d>'
end, { expr = true })

-- *で最初のマッチへ移動しないように
vim.keymap.set('n', '*', '"zyiw:let @/ = @z<CR>:<C-u>set hlsearch<CR>')
vim.keymap.set('v', '*', '"zy:let @/ = @z<CR>:<C-u>set hlsearch<CR>')

-- x/cで削除・選択した書き換え前テキストは削除レジスタへ送り、ヤンクレジスタを汚染しないように
vim.keymap.set({ 'n', 'v' }, 'x', '"_x')
vim.keymap.set({ 'n', 'v' }, 'c', '"_c')

-- 範囲選択中の貼り付け時に、ヤンクレジスタを汚染しないように
vim.keymap.set('v', 'p', 'P')

-- 改行文字を除く行末を選択しやすくする
vim.keymap.set('v', 'v', 'g_')

vim.keymap.set('i', '<Left>', '<C-g>U<Left>')
vim.keymap.set('i', '<Right>', '<C-g>U<Right>')
vim.keymap.set('i', '<Up>', '<C-g>U<Up>', { expr = true })
vim.keymap.set('i', '<Down>', '<C-g>U<Down>', { expr = true })
vim.keymap.set('i', '<Home>', keymap_actions.undoable_home, { expr = true })
vim.keymap.set('i', '<End>', keymap_actions.undoable_end, { expr = true })
vim.keymap.set('i', '<C-f>', '<C-g>U<Right>')
vim.keymap.set('i', '<C-b>', '<C-g>U<Left>')
vim.keymap.set('i', '<C-a>', keymap_actions.undoable_home, { expr = true })
vim.keymap.set('i', '<C-e>', keymap_actions.undoable_end, { expr = true })
vim.keymap.set('i', '<C-k>', '<C-o>"_D')

require('config.telescope')
require('config.oil')
require('config.neogit')

require('config.space')
