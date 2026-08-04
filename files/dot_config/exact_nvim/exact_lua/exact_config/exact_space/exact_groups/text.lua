require('which-key').add({ { '<Leader>x', group = 'Text' } })

vim.keymap.set({ 'n', 'x' }, '<Leader>xo', require('config.keymap_actions').open, { desc = 'Open' })
