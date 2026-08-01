vim.api.nvim_create_autocmd('FileType', {
  -- Telescope 系バッファでは WinEnter/BufWinEnter 時点でfiletype がまだ空文字列
  pattern = 'Telescope*',
  callback = function()
    vim.wo.cursorline = false
  end,
})

local telescope_actions = require('telescope.actions')
local telescope_action_state = require('telescope.actions.state')

-- レイアウト戦略ごとに Telescope のハイライトを差し替える。
-- colorscheme 側で `Telescope<X>_<layout_strategy>` という名前のグループを定義しておくと、その戦略で
-- 起動したときだけ `Telescope<X>` がそこへリンクされる。
-- (e.g. TelescopeNormal_ivy_hermit を定義すると ivy_hermit のときだけ TelescopeNormal に効く)
-- 定義のない戦略では colorscheme 本来の色 (tokyonight の Telescope* 定義、および telescope 本体の
-- デフォルトリンク経由で解決される色) がそのまま使われる。
--
-- ウィンドウ単位のハイライト namespace (nvim_win_set_hl_ns) では実現できなかった。telescope/plenary は
-- 各ウィンドウの背景色を winhighlight 経由の間接参照 (e.g. Normal -> TelescopeResultsNormal) で
-- 設定しており、namespace をウィンドウへ割り当てると winhighlight 自体が丸ごと無効化されて
-- 配色が崩れるため。グローバルなハイライト定義を layout_strategy に応じて都度差し替える。

-- { [layout_strategy] = { [Telescope<X>] = Telescope<X>_<layout_strategy> } }
local telescope_strategy_links
-- 差し替え対象になり得る Telescope<X> の、colorscheme 読み込み直後の定義
local telescope_baseline_highlights

local function telescope_collect_highlights()
  telescope_strategy_links = {}
  telescope_baseline_highlights = {}

  -- telescope 本来のグループ名は CamelCase で `_` を含まないため、最初の `_` で戦略名と切り分けられる
  for name in pairs(vim.api.nvim_get_hl(0, {})) do
    local target, strategy = name:match('^(Telescope[^_]+)_(.+)$')
    if target then
      telescope_strategy_links[strategy] = telescope_strategy_links[strategy] or {}
      telescope_strategy_links[strategy][target] = name

      local baseline = vim.api.nvim_get_hl(0, { name = target })
      -- default = true のまま再適用すると「未定義のときだけ適用」の意味になり no-op になる
      baseline.default = nil
      telescope_baseline_highlights[target] = baseline
    end
  end
end

-- colorscheme を読み直すと Telescope* も再定義されるため、次のピッカー起動時に取り直す
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    telescope_strategy_links = nil
    telescope_baseline_highlights = nil
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopePrompt',
  callback = function(args)
    local picker = telescope_action_state.get_current_picker(args.buf)
    if not picker then
      return
    end

    -- 初回のピッカー起動時に集める。この時点なら telescope 本体の plugin/telescope.lua による
    -- デフォルト定義も済んでおり、かつまだどの戦略のリンクも張っていない
    if not telescope_strategy_links then
      telescope_collect_highlights()
    end

    -- 前回のピッカーが張ったリンクを残さないよう、一度すべて戻してから今回の戦略のぶんを被せる
    for target, baseline in pairs(telescope_baseline_highlights) do
      vim.api.nvim_set_hl(0, target, baseline)
    end
    for target, source in pairs(telescope_strategy_links[picker.layout_strategy] or {}) do
      vim.api.nvim_set_hl(0, target, { link = source })
    end
  end,
})

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

-- buffers ピッカーでのバッファ削除: mini.bufremove でウィンドウレイアウトを保ったまま削除する
local function telescope_delete_buffer(prompt_bufnr)
  local current_picker = telescope_action_state.get_current_picker(prompt_bufnr)

  current_picker:delete_selection(function(selection)
    local force = vim.bo[selection.bufnr].buftype == 'terminal'
    return require('mini.bufremove').delete(selection.bufnr, force)
  end)
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

  layout.prompt.borderchars = { '', '', '', '', '', '', '', '' }
  layout.prompt.border = { 1, 1, 0, 1 } -- top, right, bottom, left

  layout.results.title = ''
  layout.results.border = { 0, 1, 0, 1 }
  layout.results.borderchars = { '', '', '', '', '', '', '', '' }
  layout.results.height = layout.results.height + 1

  if layout.preview then
    layout.preview.title = ''
    layout.preview.border = { 0, 1, 0, 1 }
    layout.preview.borderchars = { '', '', '', '│', '│', '', '', '' }
    layout.preview.line = layout.preview.line - 1
    layout.preview.height = layout.preview.height + 2
  end

  return layout
end

local telescope = require('telescope')

telescope.setup({
  defaults = {
    file_ignore_patterns = {
      "%.git/",
    },
    prompt_prefix = '❯ ',
    selection_caret = '▌ ',
    multi_icon = '┃',
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ['<Esc>'] = require('telescope.actions').close,
        ['<C-g>'] = require('telescope.actions').close,
        ['<C-u>'] = false, -- ビルトインのプレビュースクロールバインドを削除して、フィールドをクリアできるように
        ['<CR>'] = telescope_multi_edit,
        ['<C-x>'] = telescope_multi_open_horizontal,
        ['<C-s>'] = telescope_multi_open_horizontal,
        ['<C-v>'] = telescope_multi_open_vertical,
        ['<C-t>'] = telescope_multi_open_tab,
        ['<C-Space>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_worse,
        ['<Tab>'] = require('telescope.actions.layout').toggle_preview,
      },
      n = {
        ['<Esc>'] = require('telescope.actions').close,
        ['<C-g>'] = require('telescope.actions').close,
        ['<C-u>'] = false, -- ビルトインのプレビュースクロールバインドを削除して、フィールドをクリアできるように
        ['<CR>'] = telescope_multi_edit,
        ['<C-x>'] = telescope_multi_open_horizontal,
        ['<C-s>'] = telescope_multi_open_horizontal,
        ['<C-v>'] = telescope_multi_open_vertical,
        ['<C-t>'] = telescope_multi_open_tab,
        ['<C-Space>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_worse,
        ['<Tab>'] = require('telescope.actions.layout').toggle_preview,
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
          -- nop にしておかないとノーマルモードに戻ってしまう
          ['<C-c>'] = telescope_actions.nop,
          ['<C-c>d'] = telescope_delete_buffer,
        },
        n = {
          ['<C-c>'] = telescope_actions.nop,
          ['<C-c>d'] = telescope_delete_buffer,
        },
      },
    },
    live_grep = {
      mappings = {
        -- デフォルトが actions.to_fuzzy_refine で使いづらい
        i = {
          ['<C-Space>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_worse,
        },
        n = {
          ['<C-Space>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_worse,
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

telescope.load_extension('fzf')
