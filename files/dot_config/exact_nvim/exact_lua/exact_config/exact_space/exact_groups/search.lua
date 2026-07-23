require('which-key').add({ { '<Leader>s', group = 'Search' } })

vim.keymap.set('n', '<Leader>sd', function()
  require('telescope.builtin').live_grep({
    cwd = require('telescope.utils').buffer_dir(),
  })
end, { desc = 'Search in current directory' })
vim.keymap.set('n', '<Leader>sD', function()
  require('telescope.builtin').live_grep({
    cwd = require('telescope.utils').buffer_dir(),
    default_text = vim.fn.expand('<cword>'),
  })
end, { desc = 'Search in current directory w/ symbol under cursor' })

vim.keymap.set('n', '<Leader>sp', '<Cmd>Telescope live_grep<CR>', { desc = 'Search in a project' })
vim.keymap.set('n', '<Leader>sP', function()
  require('telescope.builtin').live_grep({
    default_text = vim.fn.expand('<cword>'),
  })
end, { desc = 'Search in a project w/ symbol under cursor' })
vim.keymap.set('n', '<Leader>/', '<Leader>sp', { remap = true, desc = 'Search in a project' })
vim.keymap.set('n', '<Leader>*', '<Leader>sP', { remap = true, desc = 'Search in a project w/ symbol under cursor' })

vim.keymap.set('n', '<Leader>ss', '<Cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = 'Search in current file' })
vim.keymap.set('n', '<Leader>sS', function()
  require('telescope.builtin').current_buffer_fuzzy_find({
    default_text = vim.fn.expand('<cword>'),
  })
end, { desc = 'Search in current file w/ symbol under cursor' })
