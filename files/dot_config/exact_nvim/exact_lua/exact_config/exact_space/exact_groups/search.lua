require('which-key').add({ { '<Leader>s', group = 'Search' } })

-- ノーマルモードではカーソル下のシンボル、ビジュアルモードでは選択範囲を返す
local function get_search_text()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    return vim.fn.expand('<cword>')
  end
  vim.cmd.normal({ vim.keycode('<Esc>'), bang = true })
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  local lines = vim.fn.getline(s[2], e[2])
  if #lines == 0 then return '' end
  lines[#lines] = string.sub(lines[#lines], 1, e[3])
  lines[1] = string.sub(lines[1], s[3])
  return table.concat(lines, ' ')
end

vim.keymap.set('n', '<Leader>sd', function()
  require('telescope.builtin').live_grep({
    cwd = require('telescope.utils').buffer_dir(),
  })
end, { desc = 'Search in current directory' })
vim.keymap.set({ 'n', 'x' }, '<Leader>sD', function()
  require('telescope.builtin').live_grep({
    cwd = require('telescope.utils').buffer_dir(),
    default_text = get_search_text(),
  })
end, { desc = 'Search in current directory w/ symbol under cursor' })

vim.keymap.set('n', '<Leader>sp', '<Cmd>Telescope live_grep<CR>', { desc = 'Search in a project' })
vim.keymap.set({ 'n', 'x' }, '<Leader>sP', function()
  require('telescope.builtin').live_grep({
    default_text = get_search_text(),
  })
end, { desc = 'Search in a project w/ symbol under cursor' })
vim.keymap.set('n', '<Leader>/', '<Leader>sp', { remap = true, desc = 'Search in a project' })
vim.keymap.set({ 'n', 'x' }, '<Leader>*', '<Leader>sP', { remap = true, desc = 'Search in a project w/ symbol under cursor' })

vim.keymap.set('n', '<Leader>ss', '<Cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = 'Search in current file' })
vim.keymap.set({ 'n', 'x' }, '<Leader>sS', function()
  require('telescope.builtin').current_buffer_fuzzy_find({
    default_text = get_search_text(),
  })
end, { desc = 'Search in current file w/ symbol under cursor' })
