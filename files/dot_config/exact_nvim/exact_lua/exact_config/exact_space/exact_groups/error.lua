require('which-key').add({
  { '<Leader>e', group = 'Error' },
  { '<Leader>e.', group = 'Error transient state' },
})

vim.keymap.set('n', '<Leader>en', ']d', { desc = 'Go to the next error', remap = true })
vim.keymap.set('n', '<Leader>ep', '[d', { desc = 'Go to the previous error', remap = true })
vim.keymap.set('n', '<Leader>eN', '<Leader>ep', { desc = 'Go to the previous error', remap = true })

vim.keymap.set('n', '<Leader>ey', function()
  local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #diags > 0 then
    local filename = vim.fn.expand('%:.')
    local errors = {}
    for _, diag in ipairs(diags) do
      -- 本家はメッセージだけらしい
      table.insert(errors, string.format('%s:%d:%d: %s', filename, diag.lnum + 1, diag.col + 1, diag.message))
    end
    local formatted = vim.fn.join(errors, '\n') .. '\n'
    vim.fn.setreg("+", formatted)
  end
end, { desc = 'Copy each error at cursor position' })

require('hydra')({
  mode = 'n',
  body = '<Leader>e.',
  heads = {
    { 'n', '<Leader>en', { desc = 'Jump to next error', remap = true } },
    { 'p', '<Leader>ep', { desc = 'Jump to previous error', remap = true } },
    { 'N', '<Leader>eN', { desc = 'Jump to previous error', remap = true } },
    { 'y', '<Leader>ey', { desc = 'Copy each error', remap = true } }, -- 本家にない
    { '<Esc>', nil, { exit = true, desc = false } },
    { '<C-g>', nil, { exit = true, desc = false } },
    { 'q', nil, { exit = true, desc = false } },
  },
  config = {
    hint = {
      type = 'window',
      show_name = false,
    },
    timeout = 5000,
    color = 'red',
  },
})
