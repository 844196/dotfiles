require('which-key').add({ { '<Leader>q', group = 'Quit' } })

vim.keymap.set('n', '<Leader>qq', '<Cmd>qa<CR>', { desc = 'Quit Neovim' })
vim.keymap.set('n', '<Leader>qQ', '<Cmd>qa!<CR>', { desc = 'Quit Neovim, lose all unsaved changes' })
vim.keymap.set('n', '<Leader>qs', '<Cmd>wqa<CR>', { desc = 'Save the buffers, quit Neovim' })

vim.keymap.set('n', '<Leader>qr', require('config.space.restart').restart_with_session, { desc = 'Restart Neovim' })
vim.keymap.set('n', '<Leader>qR', '<Cmd>restart<CR>', { desc = 'Restart Neovim without restoring session' })
