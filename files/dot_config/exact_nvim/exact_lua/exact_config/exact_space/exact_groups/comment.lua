require('which-key').add({ { '<Leader>c', group = 'Comment' } })

local function invert_lines(s, e)
  local pos = vim.api.nvim_win_get_cursor(0)
  for l = s, e do
    vim.api.nvim_win_set_cursor(0, { l, 0 })
    vim.cmd.normal({ 'gcc', bang = false })
  end
  vim.api.nvim_win_set_cursor(0, pos)
end

-- SPC ;  (operator)
vim.keymap.set({ 'n', 'x' }, '<Leader>;', 'gc',
  { remap = true, desc = 'Comment operator' })

-- SPC c l
vim.keymap.set('n', '<Leader>cl', 'gcc', { remap = true, desc = 'Comment lines' })
vim.keymap.set('x', '<Leader>cl', 'gc', { remap = true, desc = 'Comment lines' })

-- SPC c L
vim.keymap.set('n', '<Leader>cL', function()
  local s = vim.fn.line('.')
  invert_lines(s, math.min(s + vim.v.count1 - 1, vim.fn.line('$')))
end, { desc = 'Invert comment lines' })
vim.keymap.set('x', '<Leader>cL', function()
  local s, e = vim.fn.line('v'), vim.fn.line('.')
  vim.cmd('normal! \27')
  invert_lines(math.min(s, e), math.max(s, e))
end, { desc = 'Invert comment lines' })

-- SPC c p
vim.keymap.set('n', '<Leader>cp', 'gcip', { remap = true, desc = 'Comment paragraph' })
vim.keymap.set('n', '<Leader>cP', function()
  local s, e = vim.fn.line("'{") + 1, vim.fn.line("'}") - 1
  invert_lines(s, e)
end, { desc = 'Invert comment paragraph' })

-- SPC c t  ({count} SPC c t で現在行からその行まで)
vim.keymap.set('n', '<Leader>ct', function()
  local target = vim.v.count
  if target == 0 then return end
  local pos = vim.api.nvim_win_get_cursor(0)
  local cur = pos[1]
  local s, e = math.min(cur, target), math.max(cur, target)
  vim.cmd(('normal %dGV%dGgc'):format(s, e))
  vim.api.nvim_win_set_cursor(0, pos)
end, { desc = 'Comment to line' })

vim.keymap.set('n', '<Leader>cT', function()
  local target = vim.v.count
  if target == 0 then return end
  local cur = vim.fn.line('.')
  invert_lines(math.min(cur, target), math.max(cur, target))
end, { desc = 'Invert comment to line' })

local function copy_and_comment_range(s, e)
  local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
  vim.api.nvim_buf_set_lines(0, e, e, false, lines) -- 生きたコピーを下に
  vim.cmd(('normal %dGV%dGgc'):format(s, e))        -- 元をコメントアウト
end

-- SPC c y / gy  (normal)
local function copy_and_comment()
  local col = vim.fn.col('.')
  local s = vim.fn.line('.')
  local e = math.min(s + vim.v.count1 - 1, vim.fn.line('$'))
  copy_and_comment_range(s, e)
  vim.api.nvim_win_set_cursor(0, { e + 1, col - 1 })
end
vim.keymap.set('n', '<Leader>cy', copy_and_comment, { desc = 'Comment and yank' })
vim.keymap.set('n', 'gy', copy_and_comment, { desc = 'Comment and yank' })

-- SPC c y / gy  (visual: v / V / <C-v> すべて行単位に拡張)
local function copy_and_comment_visual()
  local s, e = vim.fn.line('v'), vim.fn.line('.')
  if s > e then s, e = e, s end
  vim.cmd.normal({ vim.keycode('<Esc>'), bang = true })
  copy_and_comment_range(s, e)
  vim.api.nvim_win_set_cursor(0, { e + 1, 0 })
end
vim.keymap.set('x', '<Leader>cy', copy_and_comment_visual, { desc = 'Comment and yank' })
vim.keymap.set('x', 'gy', copy_and_comment_visual, { desc = 'Comment and yank' })
