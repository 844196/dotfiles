vim.keymap.set('n', '<Leader>tn', '<Cmd>setlocal number!<CR>')
vim.keymap.set('n', '<Leader>thh', function()
  vim.o.cursorlineopt = vim.o.cursorlineopt == 'number' and 'both' or 'number'
end)
vim.keymap.set('n', '<Leader>tf', function()
  vim.o.colorcolumn = vim.o.colorcolumn ~= '120' and '120' or ''
end)
