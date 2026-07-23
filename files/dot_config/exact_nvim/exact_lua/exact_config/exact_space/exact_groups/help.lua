require('which-key').add({ { '<Leader>h', group = 'Help' } })

vim.keymap.set('n', '<Leader>h<Leader>', ':h ', { desc = 'Read help...' })
