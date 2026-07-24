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

require('config.space.hydra').create({
  body = '<Leader>e.',
  heads = {
    { 'n', '<Leader>en', { desc = 'Jump to next error', remap = true } },
    { 'p', '<Leader>ep', { desc = 'Jump to previous error', remap = true } },
    { 'N', '<Leader>eN', { desc = 'Jump to previous error', remap = true } },
    { 'z', require('config.space.recenter'), { desc = 'Recenter buffer in window' } },
    { 'y', '<Leader>ey', { desc = 'Copy each error', remap = true } }, -- 本家にない
  },
})
