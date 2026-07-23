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
    local util = require('tokyonight.util')
    hl.WinSeparator = {
      fg = util.blend_bg(colors.bg_highlight, 0.75),
    }
    hl.TelescopeNormal = {
      bg = colors.bg,
    }
    hl.TelescopeResultsNormal = {
      fg = colors.dark3,
      bg = colors.bg,
    }
    hl.TelescopeSelection = {
      bg = colors.bg_highlight,
    }
    hl.TelescopeMatching = {
      fg = colors.blue,
      bg = colors.bg,
    }
    hl.TelescopePromptPrefix = {
      fg = colors.blue,
    }
    hl.TelescopeMultiIcon = {
      fg = colors.orange,
    }
    hl.TelescopeMultiSelection = {
      fg = colors.fg,
    }
    hl.TelescopeResultsBorder = {
      fg = colors.fg_gutter,
      bg = colors.bg,
    }
    hl.TelescopePromptBorder = {
      fg = colors.fg_gutter,
      bg = colors.bg,
    }
    hl.TelescopePreviewBorder = {
      fg = colors.fg_gutter,
      bg = colors.bg,
    }
    hl.TelescopeTitle = {
      fg = colors.dark5,
    }
    hl.TelescopePromptTitle = {
      fg = colors.dark5,
    }
    hl.SnacksIndent = {
      fg = util.blend_bg(colors.fg_gutter, 0.2),
    }
    hl.SnacksIndentScope = {
      fg = colors.fg_gutter,
    }
    hl.GitSignsAdd = {
      fg = util.blend_bg(colors.green1, 0.5)
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
vim.o.cursorlineopt = 'number'

-- cursorlineopt (number/both) はグローバル状態として vim.g に保持し、各ウィンドウがアクティブになった時に反映する
vim.g.cursorlineopt_state = vim.o.cursorlineopt

-- アクティブなウィンドウだけカーソル行をハイライトする
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'FileType' }, {
  callback = function()
    -- FileType も対象にしているのは、Telescope 系バッファでは WinEnter/BufWinEnter 時点で
    -- filetype がまだ空文字列で、FileType イベントで初めて TelescopePrompt 等がセットされるため
    if vim.bo.filetype:match('^Telescope') then
      vim.wo.cursorline = false
      return
    end
    vim.wo.cursorline = true
    vim.wo.cursorlineopt = vim.g.cursorlineopt_state
  end,
})
vim.api.nvim_create_autocmd('WinLeave', {
  callback = function()
    vim.wo.cursorline = false
  end,
})

vim.o.scrolloff = 4
vim.o.sidescrolloff = 8

require('gitsigns').setup({
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = "" },
    topdelete    = { text = "" },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
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

require('mini.pairs').setup()

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
local telescope_action_state = require('telescope.actions.state')

-- entry の filename を絶対パスに正規化する
local function telescope_entry_filename(entry)
  local Path = require('plenary.path')
  local filename = entry.path or entry.filename
  if filename then
    return Path:new(filename):normalize(vim.uv.cwd())
  end
  return entry.value
end

-- grep 系ピッカーの entry であれば、開いた後にカーソル位置を合わせる
local function telescope_entry_set_cursor(entry)
  local row = entry.row or entry.lnum
  if row then
    pcall(vim.api.nvim_win_set_cursor, 0, { row, (entry.col or 1) - 1 })
  end
end

-- カーソルがあるマッチ行を画面中央に表示する (entry に行番号がある場合のみ)
local function telescope_entry_center(entry)
  if entry.row or entry.lnum then
    vim.cmd('normal! zz')
  end
end

-- 名前なし・未編集・空内容のバッファかどうか (起動直後の空バッファ相当)
local function telescope_is_empty_scratch_buffer(bufnr)
  bufnr = bufnr or 0
  if vim.api.nvim_buf_get_name(bufnr) ~= '' then
    return false
  end
  if vim.bo[bufnr].modified or vim.bo[bufnr].buftype ~= '' then
    return false
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return #lines == 0 or (#lines == 1 and lines[1] == '')
end

-- <CR>: 複数選択時は最後に選択したものだけカレントウィンドウに表示し、他はバッファ追加のみ
local function telescope_multi_edit(prompt_bufnr)
  local picker = telescope_action_state.get_current_picker(prompt_bufnr)
  local multi_selection = picker:get_multi_selection()

  if #multi_selection <= 1 then
    (telescope_actions.select_default + telescope_actions.center)(prompt_bufnr)
    return
  end

  local original_win_id = picker.original_win_id
  local replace_empty_scratch = vim.api.nvim_win_is_valid(original_win_id)
    and telescope_is_empty_scratch_buffer(vim.api.nvim_win_get_buf(original_win_id))
  local empty_scratch_bufnr = replace_empty_scratch and vim.api.nvim_win_get_buf(original_win_id) or nil

  telescope_actions.close(prompt_bufnr)

  for _, entry in ipairs(multi_selection) do
    vim.cmd('badd ' .. vim.fn.fnameescape(telescope_entry_filename(entry)))
  end

  local last_entry = multi_selection[#multi_selection]
  vim.cmd('edit ' .. vim.fn.fnameescape(telescope_entry_filename(last_entry)))
  telescope_entry_set_cursor(last_entry)
  telescope_entry_center(last_entry)

  -- badd/edit で空バッファがどこにも使われず宙に浮いた場合は削除する
  if empty_scratch_bufnr and vim.api.nvim_win_get_buf(original_win_id) ~= empty_scratch_bufnr then
    pcall(vim.cmd, 'bd ' .. empty_scratch_bufnr)
  end
end

-- <M-v>/<M-s>/<M-t>: 複数選択時は選択したファイルごとにウィンドウ (またはタブ) を追加する
-- ただし呼び出し元 (元々フォーカスしていたウィンドウ) が起動直後の空バッファなら、
-- 先頭ファイルはウィンドウ (またはタブ) を増やさずそのバッファを置き換える
local function telescope_multi_open(default_action, command)
  return function(prompt_bufnr)
    local picker = telescope_action_state.get_current_picker(prompt_bufnr)
    local multi_selection = picker:get_multi_selection()

    if #multi_selection <= 1 then
      default_action(prompt_bufnr)
      return
    end

    local original_win_id = picker.original_win_id
    local replace_empty_scratch = vim.api.nvim_win_is_valid(original_win_id)
      and telescope_is_empty_scratch_buffer(vim.api.nvim_win_get_buf(original_win_id))

    telescope_actions.close(prompt_bufnr)

    local start_index = 1
    -- (window id, entry) を記録し、全ウィンドウを開き終えてからまとめて zz する
    -- (先にウィンドウごとに zz すると、後続の分割でレイアウトが変わり中央からずれるため)
    local opened = {}

    if replace_empty_scratch then
      local empty_scratch_bufnr = vim.api.nvim_win_get_buf(original_win_id)
      local first_entry = multi_selection[1]
      vim.cmd('edit ' .. vim.fn.fnameescape(telescope_entry_filename(first_entry)))
      telescope_entry_set_cursor(first_entry)
      table.insert(opened, { win_id = original_win_id, entry = first_entry })
      -- 名前なし空バッファへの :edit は新規バッファを作らずそのまま再利用することがあるため、
      -- バッファ番号が変わった (別バッファに切り替わった) ときだけ元の空バッファを削除する
      if vim.api.nvim_win_get_buf(original_win_id) ~= empty_scratch_bufnr then
        pcall(vim.cmd, 'bd ' .. empty_scratch_bufnr)
      end
      start_index = 2
    end

    for i = start_index, #multi_selection do
      local entry = multi_selection[i]
      vim.cmd(command .. ' ' .. vim.fn.fnameescape(telescope_entry_filename(entry)))
      telescope_entry_set_cursor(entry)
      table.insert(opened, { win_id = vim.api.nvim_get_current_win(), entry = entry })
    end

    for _, item in ipairs(opened) do
      if vim.api.nvim_win_is_valid(item.win_id) then
        vim.api.nvim_set_current_win(item.win_id)
        telescope_entry_center(item.entry)
      end
    end
  end
end

local telescope_multi_open_vertical =
  telescope_multi_open(telescope_actions.select_vertical + telescope_actions.center, 'vsplit')
local telescope_multi_open_horizontal =
  telescope_multi_open(telescope_actions.select_horizontal + telescope_actions.center, 'split')
local telescope_multi_open_tab =
  telescope_multi_open(telescope_actions.select_tab + telescope_actions.center, 'tabedit')

local telescope_layout_strategies = require('telescope.pickers.layout_strategies')
telescope_layout_strategies.ivy_hermit = function(picker, max_columns, max_lines, layout_config)
  local layout = telescope_layout_strategies.bottom_pane(picker, max_columns, max_lines, layout_config)

  layout.prompt.title = ''
  layout.prompt.border = { 1, 0, 0, 0 } -- top, right, bottom, left

  layout.results.title = ''
  layout.results.border = { 0, 0, 0, 0 }
  layout.results.height = layout.results.height + 1

  if layout.preview then
    layout.preview.title = ''
    layout.preview.border = { 0, 0, 0, 1 }
    layout.preview.borderchars = { '', '', '', '│', '│', '', '', '' }
    layout.preview.col = layout.preview.col - 1
    layout.preview.width = layout.preview.width + 1
    layout.preview.line = layout.preview.line - 1
    layout.preview.height = layout.preview.height + 2
  end

  return layout
end

require('telescope').setup({
  defaults = {
    file_ignore_patterns = {
      "%.git/",
    },
    layout_strategy = 'ivy_hermit',
    prompt_prefix = '❯ ',
    selection_caret = '▌ ',
    multi_icon = '┃',
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ['<Esc>'] = require('telescope.actions').close,
        ['<C-u>'] = false, -- ビルトインのプレビュースクロールバインドを削除して、フィールドをクリアできるように
        ['<CR>'] = telescope_multi_edit,
        ['<M-s>'] = telescope_multi_open_horizontal,
        ['<M-v>'] = telescope_multi_open_vertical,
        ['<M-t>'] = telescope_multi_open_tab,
        ['<M-p>'] = require('telescope.actions.layout').toggle_preview,
      },
      n = {
        ['<Esc>'] = require('telescope.actions').close,
        ['<C-u>'] = false, -- ビルトインのプレビュースクロールバインドを削除して、フィールドをクリアできるように
        ['<CR>'] = telescope_multi_edit,
        ['<M-s>'] = telescope_multi_open_horizontal,
        ['<M-v>'] = telescope_multi_open_vertical,
        ['<M-t>'] = telescope_multi_open_tab,
        ['<M-p>'] = require('telescope.actions.layout').toggle_preview,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true,
      no_ignore = true,
      previewer = false,
    },
    buffers = {
      mappings = {
        i = {
          ['<M-x>'] = telescope_actions.delete_buffer,
        },
        n = {
          ['<M-x>'] = telescope_actions.delete_buffer,
        },
      },
    },
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

require('oil').setup({
  view_options = {
    show_hidden = true
  },
  keymaps = {
    ['q'] = { 'actions.close', mode = 'n' },
    ['<M-p>'] = { 'actions.preview', mode = 'n' },
    ['<M-s>'] = { 'actions.select', mode = 'n', opts = { horizontal = true } },
    ['<M-v>'] = { 'actions.select', mode = 'n', opts = { vertical = true } },
    ['<M-t>'] = { 'actions.select', mode = 'n', opts = { tab = true } },
  }
})

require('config.space')
