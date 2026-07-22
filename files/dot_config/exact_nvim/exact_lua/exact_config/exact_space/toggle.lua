vim.keymap.set('n', '<Leader>tnn', '<Cmd>windo set number!<CR>')
vim.keymap.set('n', '<Leader>thh', function()
  vim.g.cursorlineopt_state = vim.g.cursorlineopt_state == 'number' and 'both' or 'number'
  vim.wo.cursorlineopt = vim.g.cursorlineopt_state
end)
vim.keymap.set('n', '<Leader>tf', function()
  vim.o.colorcolumn = vim.o.colorcolumn ~= '120' and '120' or ''
end)
