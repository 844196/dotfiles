require('which-key').add({ { '<Leader>p', group = 'Project' } })

vim.keymap.set('n', '<Leader>pf', '<Cmd>Telescope find_files<CR>', { desc = 'Find file' })
vim.keymap.set('n', '<Leader>pD', '<Cmd>Oil .<CR>', { desc = 'Open project root in oil' })
vim.keymap.set('n', '<Leader>pr', function() require('telescope.builtin').oldfiles({ only_cwd = true }) end, { desc = 'Open a recent file' })
