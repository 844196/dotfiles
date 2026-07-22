vim.keymap.set('n', '<Leader>bb', '<Cmd>Telescope buffers<CR>')

vim.keymap.set('n', '<Leader>bs', function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(buf) == [[*scratch*]] then
      vim.api.nvim_set_current_buf(buf)
      return
    end
  end
  -- https://vi.stackexchange.com/a/21390
  vim.cmd('enew')
  vim.cmd('setlocal buftype=nofile bufhidden=hide noswapfile')
  vim.cmd([[file *scratch*]])
end, { desc = 'Switch to the scratch buffer' })

vim.keymap.set('n', '<Leader>bNn', '<Cmd>enew<CR>', { desc = 'Create new empty buffer in current window' })
vim.keymap.set('n', '<Leader>bNh', '<Cmd>leftabove vnew<CR>', { desc = 'Create new empty buffer in a new window on the left' })
vim.keymap.set('n', '<Leader>bNj', '<Cmd>belowright new<CR>', { desc = 'Create new empty buffer in a new window at the bottom' })
vim.keymap.set('n', '<Leader>bNk', '<Cmd>aboveleft new<CR>', { desc = 'Create new empty buffer in a new window above' })
vim.keymap.set('n', '<Leader>bNl', '<Cmd>belowright vnew<CR>', { desc = 'Create new empty buffer in a new window below' })

vim.keymap.set('n', '<Leader>bd', '<Cmd>bd<CR>', { desc = 'Kill the current buffer' })
vim.keymap.set('n', '<Leader>b<C-d>', function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    -- unkillable-scratch
    if buf ~= current and vim.fn.bufname(buf) ~= [[*scratch*]] then
      pcall(vim.api.nvim_buf_delete, buf, {})
    end
  end
end, { desc = 'Kill other buffers' })
