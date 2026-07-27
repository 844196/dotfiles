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
    layout_strategy = 'ivy_hermit',
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

telescope.load_extension('fzf')
