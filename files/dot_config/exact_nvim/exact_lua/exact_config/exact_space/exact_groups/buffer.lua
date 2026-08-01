require('which-key').add({ { '<Leader>b', group = 'Buffer' } })

local M = {}

M.hydra = require('config.hydra').create({
  name = 'Buffer',
  body = '<Leader>b.',
  heads = {
    {
      'b',
      function()
        require('telescope.builtin').buffers({
          layout_strategy = 'ivy_hermit',
          attach_mappings = function(prompt_bufnr)
            -- どのキーで閉じられたかに関わらず (選択・複数選択・キャンセル)
            -- prompt バッファは必ず BufWipeout されるので、それを機に hydra へ戻る
            -- BufWipeout は telescope が自身のウィンドウを閉じている最中 (nvim_win_close の中) に
            -- 同期的に発火するため、その場で :activate() すると hydra のヒント用フロートを
            -- 開けずに E1159 で失敗する。イベントループの次ティックまで遅延させる。
            vim.api.nvim_create_autocmd('BufWipeout', {
              buffer = prompt_bufnr,
              once = true,
              callback = function() vim.schedule(function() M.hydra:activate() end) end,
            })
            return true
          end,
        })
      end,
      { desc = 'Buffer list', exit = true },
    },
    { 'n', '<Cmd>bn<CR>', { desc = 'Go to next buffer' } },
    { 'p', '<Cmd>bp<CR>', { desc = 'Go to previous buffer' } },
    { 'N', '<Cmd>bp<CR>', { desc = 'Go to previous buffer' } },
    { '<Right>', '<Cmd>bn<CR>', { desc = 'Go to next buffer' } },
    { '<Left>', '<Cmd>bp<CR>', { desc = 'Go to previous buffer' } },
    { '<C-d>', '<Cmd>hide<CR>', { desc = 'Bury current buffer' } },
    { 'd', function() require('mini.bufremove').delete() end, { desc = 'Kill the current buffer' } },
    { 'x', '<Cmd>bd<CR>', { desc = 'Kill the current buffer and window' } },
    { '<C-1>', '1<C-w>w', { desc = 'Go to window #1' } },
    { '<C-2>', '2<C-w>w', { desc = 'Go to window #2' } },
    { '<C-3>', '3<C-w>w', { desc = 'Go to window #3' } },
    { '<C-4>', '4<C-w>w', { desc = 'Go to window #4' } },
    { '<C-5>', '5<C-w>w', { desc = 'Go to window #5' } },
    { '<C-6>', '6<C-w>w', { desc = 'Go to window #6' } },
    { '<C-7>', '7<C-w>w', { desc = 'Go to window #7' } },
    { '<C-8>', '8<C-w>w', { desc = 'Go to window #8' } },
    { '<C-9>', '9<C-w>w', { desc = 'Go to window #9' } },
    { 'o', '<C-w>w', { desc = 'Switch focus to other window' } },
    { 'z', require('config.keymap_actions').recenter, { desc = 'Recenter buffer in window' } },

    { 'w', function()
      -- 同期発火するイベントとの競合を避けるため、次のイベントループまで activate を遅延させる
      vim.schedule(function() require('config.space.groups.window').hydra:activate() end)
    end, { exit = true, desc = 'Window' } },
  },
})

vim.keymap.set('n', '<Leader><Tab>', '<C-^>', { desc = 'Switch to previous buffer' })
vim.keymap.set('n', '<Leader>bn', '<Cmd>bn<CR>', { desc = 'Switch to next buffer' })
vim.keymap.set('n', '<Leader>bp', '<Cmd>bp<CR>', { desc = 'Switch to previous buffer' })

vim.keymap.set('n', '<Leader>bb', '<Cmd>Telescope buffers layout_strategy=ivy_hermit<CR>', { desc = 'Switch to a buffer' })

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

return M
