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

-- 既にインストール済みのパーサーに対しては no-op
require('nvim-treesitter').install({
  "bash",
  "c",
  "diff",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "printf",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
})
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    -- パーサーが未インストールのfiletypeでは vim.treesitter.start が失敗するだけなので pcall で無視する
    if lang and pcall(vim.treesitter.start, ev.buf, lang) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'codebook',
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
      fg = '#0e0e14',
      bold = true,
    }
    local decreased_hint = util.blend_bg(colors.hint, 0.4)
    hl.DiagnosticVirtualTextHint = {
      fg = decreased_hint,
      bg = util.blend_bg(decreased_hint, 0.1),
    }
    hl.FloatTitle = {
      fg = colors.purple,
      bg = colors.bg_statusline,
      bold = true,
    }
    hl.TelescopeNormal = {
      bg = colors.bg_statusline,
    }
    hl.TelescopeResultsNormal = {
      fg = colors.dark5,
      bg = colors.bg_statusline,
    }
    hl.TelescopeSelection = {
      bg = util.blend_bg(colors.bg_highlight, 0.5, colors.bg_statusline),
    }
    hl.TelescopeMatching = {
      fg = colors.blue,
      bg = colors.bg_statusline,
    }
    hl.TelescopePromptPrefix = {
      fg = colors.blue,
    }
    hl.TelescopeMultiIcon = {
      fg = colors.fg,
    }
    hl.TelescopeMultiSelection = {
      fg = colors.fg,
    }
    hl.TelescopeResultsBorder = {
      bg = colors.bg_statusline,
    }
    hl.TelescopePreviewBorder = {
      fg = util.blend_bg(colors.bg_highlight, 0.75, colors.bg_statusline),
      bg = colors.bg_statusline,
      bold = true,
    }
    hl.TelescopePromptTitle = hl.FloatTitle

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

require('snacks').setup({
  indent = {
    enabled = true,
    animate = { enabled = false },
  },
})

require('vim._core.ui2').enable({
  enable = true,
  msg = {
    targets = 'msg'
  }
})

vim.opt.cmdheight = 0

require('config.lualine')

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

vim.opt.virtualedit:append('block')

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

vim.keymap.set('n', '<M-;>',  'gcc', { remap = true })
vim.keymap.set('i', '<M-;>', function()
  local win = vim.api.nvim_get_current_win()
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  local old_line = vim.api.nvim_get_current_line()
  require('vim._comment').toggle_lines(row, row, { row, 0 })
  local new_line = vim.api.nvim_get_current_line()
  local new_col = col + (#new_line - #old_line)
  vim.api.nvim_win_set_cursor(win, { row, math.min(math.max(new_col, 0), #new_line) })
end)
vim.keymap.set('v', '<M-;>',  'gc', { remap = true })

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

vim.keymap.set('n', '<C-l>', require('recenter'))

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

require('config.telescope')

local function oil_select_keeping_focus(select_opts)
  return function()
    local oil = require('oil')
    local winid = vim.api.nvim_get_current_win()
    oil.select(select_opts, function()
      vim.api.nvim_set_current_win(winid)
    end)
  end
end

require('oil').setup({
  view_options = {
    show_hidden = true
  },
  keymaps = {
    ['<Esc>'] = { 'actions.close', mode = 'n' },
    ['<C-g>'] = { 'actions.close', mode = 'n' },
    ['q'] = { 'actions.close', mode = 'n' },
    ['<C-h>'] = false,
    ['<C-x>'] = {
      desc = 'Open the entry in a horizontal split, keeping focus on oil',
      mode = 'n',
      callback = oil_select_keeping_focus({ horizontal = true }),
    },
    ['<C-s>'] = {
      desc = 'Open the entry in a horizontal split, keeping focus on oil',
      mode = 'n',
      callback = oil_select_keeping_focus({ horizontal = true }),
    },
    ['<C-v>'] = {
      desc = 'Open the entry in a vertical split, keeping focus on oil',
      mode = 'n',
      callback = oil_select_keeping_focus({ vertical = true }),
    },
  }
})

do
  -- mappings 設定はキー割り当てのみで挙動は変更できないため、アクション関数自体をラップする
  local status_actions = require('neogit.buffers.status.actions')

  local function keep_focus(action_name)
    local original = status_actions[action_name]
    status_actions[action_name] = function(self)
      local fn = original(self)
      return function()
        local winid = vim.api.nvim_get_current_win()
        fn()
        if vim.api.nvim_win_is_valid(winid) then
          vim.api.nvim_set_current_win(winid)
        end
      end
    end
  end

  keep_focus('n_split_open')
  keep_focus('n_vertical_split_open')
end

require('neogit').setup({
  kind = 'auto',
  treesitter_diff_highlight = true,
  word_diff_highlight = true,
  mappings = {
    status = {
      ['<Esc>'] = 'Close',
      ['<C-g>'] = 'Close',
      ['<c-s>'] = 'SplitOpen',
    },
  },
  builders = {
    NeogitCommitPopup = function(builder)
      builder:new_action_group('Claude'):action('C', 'Claude Commit', function()
        local git = require('neogit.lib.git')
        local process = require('neogit.process')
        local runner = require('neogit.runner')

        vim.ui.input({ prompt = 'Claude Commit note: ' }, function(note)
          if note == nil then
            return
          end

          local cmd = { 'git', '--no-pager', '--no-optional-locks', 'claude-commit', '--no-resume' }
          if note ~= '' then
            table.insert(cmd, note)
          end

          local proc = process.new({
            cmd = cmd,
            cwd = git.repo.worktree_root,
            env = {},
            on_error = function()
              return false
            end,
            git_hook = true,
            suppress_console = false,
            user_command = true,
          })
          proc:show_console()

          runner.call(proc, { pty = true })
        end)
      end)
    end,
    NeogitResetPopup = function(builder)
      builder:action('.', 'HEAD~    (mixed)', function()
        local git = require('neogit.lib.git')
        local notification = require('neogit.lib.notification')
        local event = require('neogit.lib.event')

        local target = 'HEAD~'
        if git.reset.mixed(target) then
          notification.info('Reset to ' .. target)
          event.send('Reset', { commit = target, mode = 'mixed' })
        else
          notification.error('Reset Failed')
        end
      end)
    end,
  },
})

require('config.space')
