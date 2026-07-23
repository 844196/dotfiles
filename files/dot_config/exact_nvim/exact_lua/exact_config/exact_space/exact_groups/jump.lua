require('which-key').add({ { '<Leader>j', group = 'Jump' } })

vim.keymap.set('n', '<Leader>jb', '<C-o>zz', { desc = 'Go back to previous location' })
vim.keymap.set('n', '<Leader>jc', '`.zz', { desc = 'Go to last change' })
