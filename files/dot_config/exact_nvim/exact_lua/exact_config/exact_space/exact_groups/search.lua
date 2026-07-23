require('which-key').add({ { '<Leader>s', group = 'Search' } })

vim.keymap.set('n', '<Leader>sp', '<Cmd>Telescope live_grep<CR>', { desc = 'Search in a project' })
vim.keymap.set('n', '<Leader>ss', '<Cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = 'Search in current file' })
