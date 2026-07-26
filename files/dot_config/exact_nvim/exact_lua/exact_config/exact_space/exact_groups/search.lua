require('which-key').add({ { '<Leader>s', group = 'Search' } })

local util = require('config.space.util')

local function get_search_text()
  return util.selection_or(function() return vim.fn.expand('<cword>') end)
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
