require('which-key').add({
  { '<Leader>b', group = 'Buffer' },
  { '<Leader>b.', desc = 'Buffer transient state' },
})

local buffer_hydra_heads = {
  { '<Esc>', nil, { exit = true, desc = false } },
  { 'q', nil, { exit = true, desc = false } },

  { 'n', '<Cmd>bn<CR>', { desc = 'Go to next buffer' } },
  { 'p', '<Cmd>bp<CR>', { desc = 'Go to previous buffer' } },
  { 'N', '<Cmd>bp<CR>', { desc = 'Go to previous buffer' } },
  { '<Right>', '<Cmd>bn<CR>', { desc = 'Go to next buffer' } },
  { '<Left>', '<Cmd>bp<CR>', { desc = 'Go to previous buffer' } },
  { '<C-d>', '<Cmd>hide<CR>', { desc = 'Bury current buffer' } },
  { 'd', function() require('mini.bufremove').delete() end, { desc = 'Kill the current buffer' } },
  { 'x', '<Cmd>bd<CR>', { desc = 'Kill the current buffer and window' } },
  { 'o', '<C-w>w', { desc = 'Switch focus to other window' } },
}

local Hydra = require('hydra')
Hydra({
  mode = 'n',
  body = '<Leader>b.',
  heads = buffer_hydra_heads,
  config = {
    hint = {
      type = 'window',
      show_name = false,
    },
    timeout = 5000,
    color = 'red',
  },
})

vim.keymap.set('n', '<Leader><Tab>', '<C-^>', { desc = 'Switch to previous buffer' })
vim.keymap.set('n', '<Leader>bn', '<Cmd>bn<CR>', { desc = 'Switch to next buffer' })
vim.keymap.set('n', '<Leader>bp', '<Cmd>bp<CR>', { desc = 'Switch to previous buffer' })

vim.keymap.set('n', '<Leader>bb', '<Cmd>Telescope buffers<CR>', { desc = 'Switch to a buffer' })

vim.keymap.set('n', '<Leader>bm', function()
  local name = '*Messages*'
  local buf
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(b) == name then buf = b break end
  end
  if not buf then
    buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf, name)
    vim.bo[buf].bufhidden = 'hide'
    vim.bo[buf].swapfile = false
    vim.bo[buf].buflisted = true -- :ls に出るように
  end
  local out = vim.api.nvim_exec2('messages', { output = true }).output
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(out, '\n'))
  vim.bo[buf].modifiable = false
  vim.api.nvim_set_current_buf(buf)
  vim.cmd('normal! G')
end, { desc = 'Open messages history' })
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
vim.keymap.set('n', '<Leader>bNl', '<Cmd>belowright vnew<CR>', { desc = 'Create new empty buffer in a new window on the right' })

local killed_file_buffers = {}

vim.api.nvim_create_autocmd('BufDelete', {
  group = vim.api.nvim_create_augroup('config.space.buffer.killed_file_buffers', {}),
  callback = function(args)
    if vim.bo[args.buf].buftype == '' and vim.fn.buflisted(args.buf) == 1 and args.file ~= '' then
      table.insert(killed_file_buffers, args.file)
    end
  end,
})

vim.keymap.set('n', '<Leader>bd', function() require('mini.bufremove').delete() end, { desc = 'Kill the current buffer' })
vim.keymap.set('n', '<Leader>bx', '<Cmd>bd<CR>', { desc = 'Kill the current buffer and window' })
vim.keymap.set('n', '<Leader>b<C-d>', function()
  if vim.fn.confirm('Kill other buffers?', '&Yes\n&No', 2) ~= 1 then
    return
  end
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    -- unkillable-scratch
    if buf ~= current and vim.fn.bufname(buf) ~= [[*scratch*]] then
      pcall(vim.api.nvim_buf_delete, buf, {})
    end
  end
end, { desc = 'Kill other buffers' })
vim.keymap.set('n', '<Leader>bu', function()
  local file = table.remove(killed_file_buffers)
  if file then
    vim.cmd.edit(vim.fn.fnameescape(file))
  end
end, { desc = 'Reopen the most recently killed file buffer' })

vim.keymap.set('n', '<Leader>bR', '<Cmd>e!<CR>', { desc = 'Revert the current buffer' })
vim.keymap.set('n', '<Leader>be', function()
  if vim.fn.confirm('Erase the content of the buffer?', '&Yes\n&No', 2) ~= 1 then
    return
  end
  vim.cmd('%d _')
end, { desc = 'Erase the content of the buffer' })
vim.keymap.set('n', '<Leader>bY', '<Cmd>%y<CR>', { desc = 'Copy whole buffer to clipboard' })
vim.keymap.set('n', '<Leader>bP', '<Cmd>%d _<CR>P', { desc = 'Copy clipboard and replace buffer' })
