require('which-key').add({ { '<Leader>e', group = 'Error' } })

local function is_qf_visible()
  return vim.fn.getqflist({ winid = 0 }).winid ~= 0
end

---@param dir 'prev'|'next'
local function jump(dir)
  if is_qf_visible() then
    local ok, err = pcall(vim.cmd, dir == 'prev' and 'cprev' or 'cnext')
    if ok then
      return
    end
    if err:match('E553') then
      vim.cmd(dir == 'prev' and 'clast' or 'cfirst')
    else
      vim.notify(err, vim.log.levels.WARN)
    end
  else
    vim.diagnostic.jump({ severity = vim.diagnostic.severity.WARN, count = dir == 'prev' and -1 or 1, wrap = false })
  end
end

local function toggle_qf_window()
  if is_qf_visible() then
    vim.cmd.cclose()
  else
    vim.cmd('copen | wincmd p')
  end
end

vim.keymap.set('n', '<Leader>en', function() jump('next') end, { desc = 'Go to the next error' })
vim.keymap.set('n', '<Leader>ep', function() jump('prev') end, { desc = 'Go to the previous error' })
vim.keymap.set('n', '<Leader>eN', '<Leader>ep', { desc = 'Go to the previous error', remap = true })

vim.keymap.set('n', '<Leader>el', toggle_qf_window, { desc = 'Open/Close quickfix window' })
vim.keymap.set('n', '<Leader>eL', '<Cmd>copen<CR>', { desc = 'Focus quickfix window' })

vim.keymap.set('n', '<Leader>eq', vim.diagnostic.setqflist, { desc = 'Set quickfix list from vim.diagnostic' })
vim.keymap.set('n', '<Leader>ec', '<Cmd>cexpr [] | cclose<CR>', { desc = 'Clear quickfix list' })

vim.keymap.set('n', '<Leader>ex', function() vim.diagnostic.open_float({ border = 'rounded' }) end, { desc = 'Hover diagnostic messages' })

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
  },
})
