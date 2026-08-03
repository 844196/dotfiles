require('which-key').add({ { '<Leader>e', group = 'Error' } })

---@param dir ('prev'|'next')?
local jump = function(dir)
  vim.diagnostic.jump({
    severity = vim.diagnostic.severity.WARN,
    count = dir == 'prev' and -1 or 1,
    wrap = false,
  })
end

vim.keymap.set('n', '<Leader>en', function() jump('next') end, { desc = 'Go to the next error' })
vim.keymap.set('n', '<Leader>ep', function() jump('prev') end, { desc = 'Go to the previous error' })
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

require('config.hydra').create({
  name = 'Error',
  body = '<Leader>e.',
  heads = {
    { 'n', '<Leader>en', { desc = 'Jump to next error', remap = true } },
    { 'p', '<Leader>ep', { desc = 'Jump to previous error', remap = true } },
    { 'N', '<Leader>eN', { desc = 'Jump to previous error', remap = true } },
    { 'z', require('config.keymap_actions').recenter, { desc = 'Recenter buffer in window' } },
    { 'y', '<Leader>ey', { desc = 'Copy each error', remap = true } }, -- 本家にない
  },
})

local function toggle_quickfix_window()
  local wins = vim.fn.getwininfo()
  for _, win in ipairs(wins) do
    if win.quickfix == 1 then
      vim.cmd.cclose()
      return
    end
  end
  vim.cmd.copen()
end

vim.keymap.set('n', '<Leader>eqn', '<Cmd>cnext<CR>')
vim.keymap.set('n', '<Leader>eqp', '<Cmd>cprev<CR>')
vim.keymap.set('n', '<Leader>eqN', '<Cmd>cprev<CR>')
vim.keymap.set('n', '<Leader>eql', toggle_quickfix_window)
vim.keymap.set('n', '<Leader>eqC', '<Cmd>cexpr [] | cclose<CR>')

require('config.hydra').create({
  name = 'Quickfix',
  body = '<Leader>eq.',
  heads = {
    { 'n', '<Cmd>cnext<CR>', { desc = 'next' } },
    { 'p', '<Cmd>cprev<CR>', { desc = 'prev' } },
    { 'N', '<Cmd>cprev<CR>', { desc = 'prev' } },
    { 'l', toggle_quickfix_window, { desc = 'open/close quickfix window' } },
    { 'C', '<Cmd>cexpr [] | cclose<CR>', { desc = 'clear', exit = true } },
  },
})
