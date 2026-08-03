require('which-key').add({ { '<Leader>s', group = 'Search' } })

local cursor = require('config.cursor')

local function get_search_text()
  return cursor.region_or(cursor.cword)
end

local get_ivy_hermit = require('config.telescope.themes').get_ivy_hermit

vim.keymap.set('n', '<Leader>sd', function()
  require('telescope.builtin').live_grep(get_ivy_hermit({
    cwd = require('telescope.utils').buffer_dir(),
  }))
end, { desc = 'Search in current directory' })
vim.keymap.set({ 'n', 'x' }, '<Leader>sD', function()
  require('telescope.builtin').live_grep(get_ivy_hermit({
    cwd = require('telescope.utils').buffer_dir(),
    default_text = get_search_text(),
  }))
end, { desc = 'Search in current directory w/ symbol under cursor' })

-- root 直下のディレクトリ名一覧に `.`/`..` を加えた候補を返す
local function list_directory_entries(root)
  local fd = vim.system({
    'fd', '--type', 'd', '--min-depth', '1', '--max-depth', '1',
    '--strip-cwd-prefix', '--hidden', '--no-ignore-vcs', '--exclude', '.git', '--exclude', 'node_modules',
  }, { cwd = root, text = true }):wait()

  local children = {}
  for line in (fd.stdout or ''):gmatch('[^\n]+') do
    table.insert(children, line)
  end
  table.sort(children)

  local entries = { '.', '..' }
  vim.list_extend(entries, children)
  return entries
end

local function directory_finder(root)
  return require('telescope.finders').new_table({
    results = list_directory_entries(root),
    entry_maker = function(line)
      local icon, hl = require('mini.icons').get('directory', line)
      return {
        value = line,
        display = function(entry)
          return icon .. ' ' .. entry.value, { { { 0, #icon }, hl } }
        end,
        ordinal = line,
      }
    end,
  })
end

-- root 直下のディレクトリを一覧表示し、選択すると同じピッカーの中身だけ差し替えて潜る (`..` は親へ、`.` は root を live_grep 対象として確定)
local function navigate_directory_picker(root, default_text)
  local current_root = root
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  require('telescope.pickers').new(get_ivy_hermit(), {
    prompt_title = 'Search in Directory (' .. root .. ')',
    finder = directory_finder(root),
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function go_to(new_root)
        current_root = new_root
        local picker = action_state.get_current_picker(prompt_bufnr)
        picker:refresh(directory_finder(new_root), { reset_prompt = true })
        if picker.layout.prompt.border then
          picker.layout.prompt.border:change_title('Search in Directory (' .. new_root .. ')')
        end
      end

      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        if entry.value == '.' then
          actions.close(prompt_bufnr)
          require('telescope.builtin').live_grep(get_ivy_hermit({ cwd = current_root, default_text = default_text }))
        elseif entry.value == '..' then
          go_to(vim.fs.dirname(current_root))
        else
          -- fd の `--type d` 出力は末尾に `/` が付くため、パス演算に使う前に取り除く
          go_to(current_root .. '/' .. (entry.value:gsub('/$', '')))
        end
      end)
      -- 何も入力されていない状態での <C-h>/<BS> は親ディレクトリへ移動、それ以外は通常の backspace
      local function backspace_or_go_to_parent()
        if action_state.get_current_line() == '' then
          go_to(vim.fs.dirname(current_root))
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<BS>', true, false, true), 'n', true)
        end
      end
      map('i', '<C-h>', backspace_or_go_to_parent)
      map('i', '<BS>', backspace_or_go_to_parent)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<Leader>sf', function()
  navigate_directory_picker(require('telescope.utils').buffer_dir())
end, { desc = 'Search in a directory' })
vim.keymap.set({ 'n', 'x' }, '<Leader>sF', function()
  navigate_directory_picker(require('telescope.utils').buffer_dir(), get_search_text())
end, { desc = 'Search in a directory w/ symbol under cursor' })

vim.keymap.set('n', '<Leader>sp', function() require('telescope.builtin').live_grep(get_ivy_hermit()) end, { desc = 'Search in a project' })
vim.keymap.set({ 'n', 'x' }, '<Leader>sP', function()
  require('telescope.builtin').live_grep(get_ivy_hermit({
    default_text = get_search_text(),
  }))
end, { desc = 'Search in a project w/ symbol under cursor' })
vim.keymap.set('n', '<Leader>/', '<Leader>sp', { remap = true, desc = 'Search in a project' })
vim.keymap.set({ 'n', 'x' }, '<Leader>*', '<Leader>sP', { remap = true, desc = 'Search in a project w/ symbol under cursor' })

vim.keymap.set('n', '<Leader>sb', function()
  require('telescope.builtin').live_grep(get_ivy_hermit({
    grep_open_files = true,
  }))
end, { desc = 'Search in opened buffers' })
vim.keymap.set({ 'n', 'x' }, '<Leader>sB', function()
  require('telescope.builtin').live_grep(get_ivy_hermit({
    grep_open_files = true,
    default_text = get_search_text(),
  }))
end, { desc = 'Search in opened buffers w/ symbol under cursor' })

vim.keymap.set({ 'n', 'x' }, '<Leader>ss', function()
  require('telescope.builtin').current_buffer_fuzzy_find(get_ivy_hermit({
    default_text = get_search_text(),
  }))
end, { desc = 'Search in current file w/ symbol under cursor' })

-- TODO: 本家の helm-multi-swoop は検索対象のバッファを選択できる SPC s B に近い？
vim.keymap.set({ 'n', 'x' }, '<Leader>sS', function()
  require('telescope.builtin').current_buffer_fuzzy_find(get_ivy_hermit({
    default_text = get_search_text(),
  }))
end, { desc = '?' })
