require('which-key').add({ { '<Leader>t', group = 'Toggle' } })

vim.keymap.set('n', '<Leader>tnn', require('config.number').toggle_number)
vim.keymap.set('n', '<Leader>tna', require('config.number').toggle_absolute)
vim.keymap.set('n', '<Leader>tnr', require('config.number').toggle_relative)

vim.keymap.set('n', '<Leader>thh', require('config.cursorline').toggle)

vim.keymap.set('n', '<Leader>tf', function()
  vim.o.colorcolumn = vim.o.colorcolumn ~= '120' and '120' or ''
end)

vim.keymap.set('n', '<Leader>tS', require('config.spellcheck').toggle, { desc = 'Toggle spell check' })

vim.keymap.set('n', '<Leader>TZ', require('no-neck-pain').toggle, { desc = 'Toggle no-neck-pain' })
