vim.bo.bufhidden = 'delete'
vim.cmd('wincmd L')
vim.keymap.set('n', 'q', '<Cmd>bd<CR>', { buf = 0 })
