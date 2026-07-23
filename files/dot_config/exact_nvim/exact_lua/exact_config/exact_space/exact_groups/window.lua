require('which-key').add({
  { '<Leader>w', group = 'Window' },
  { '<Leader>w.', desc = 'Window transient state' },
})

local window_hydra_heads = {
  { '<Esc>', nil, { exit = true, desc = false } },
  { 'q', nil, { exit = true, desc = false } },

  -- split
  { 'S', '<C-w>s', { desc = 'Horizontal split and focus new window' } },
  { 'V', '<C-w>v', { desc = 'Vertical split and focus new window' } },
  { 's', '<C-w>s', { desc = 'Horizontal split and focus new window' } }, -- 本家が微妙
  { 'v', '<C-w>v', { desc = 'Vertical split and focus new window' } }, -- 本家が微妙

  -- focus
  { '1', '1<C-w>w', { desc = 'Go to window #1' } },
  { '2', '2<C-w>w', { desc = 'Go to window #2' } },
  { '3', '3<C-w>w', { desc = 'Go to window #3' } },
  { '4', '4<C-w>w', { desc = 'Go to window #4' } },
  { '5', '5<C-w>w', { desc = 'Go to window #5' } },
  { '6', '6<C-w>w', { desc = 'Go to window #6' } },
  { '7', '7<C-w>w', { desc = 'Go to window #7' } },
  { '8', '8<C-w>w', { desc = 'Go to window #8' } },
  { '9', '9<C-w>w', { desc = 'Go to window #9' } },
  { 'w', '<C-w>w', { desc = 'Focus other window' } },
  { 'h', '<C-w>h', { desc = 'Go to window on the left' } },
  { 'j', '<C-w>j', { desc = 'Go to window below' } },
  { 'k', '<C-w>k', { desc = 'Go to window above' } },
  { 'l', '<C-w>l', { desc = 'Go to window on the right' } },
  { '<Left>', '<C-w>h', { desc = 'Go to window on the left' } },
  { '<Down>', '<C-w>j', { desc = 'Go to window below' } },
  { '<Up>', '<C-w>k', { desc = 'Go to window above' } },
  { '<Right>', '<C-w>l', { desc = 'Go to window on the right' } },

  -- move
  { 'H', '<C-w>H', { desc = 'Move window to the left' } },
  { 'J', '<C-w>J', { desc = 'Move window to the bottom' } },
  { 'K', '<C-w>K', { desc = 'Move window to the top' } },
  { 'L', '<C-w>L', { desc = 'Move window to the right' } },
  { '<S-Left>', '<C-w>H', { desc = 'Move window to the left' } },
  { '<S-Down>', '<C-w>J', { desc = 'Move window to the bottom' } },
  { '<S-Up>', '<C-w>K', { desc = 'Move window to the top' } },
  { '<S-Right>', '<C-w>L', { desc = 'Move window to the right' } },
  { 'r', '<C-w>r', { desc = 'Rotate windows forward' } },
  { 'R', '<C-w>R', { desc = 'Rotate windows backward' } },

  -- resize
  { '[', '<C-w><', { desc = 'Shrink window horizontally' } },
  { ']', '<C-w>>', { desc = 'Enlarge window horizontally' } },
  { '{', '<C-w>-', { desc = 'Shrink window vertically' } },
  { '}', '<C-w>+', { desc = 'Enlarge window vertically' } },
  { 'm', function() require('snacks.zen').zoom() end, { desc = 'Maximize a window' } },
  { '=', '<C-w>=', { desc = 'Balance split windows' } },

  -- delete
  { 'd', '<Cmd>close!<CR>', { desc = 'Delete window' } },
  { 'D', '<Cmd>only<CR>', { desc = 'Delete other windows' } },
  { 'x', '<Cmd>bd<CR>', { desc = 'Delete window and kill buffer' } },
}

local Hydra = require('hydra')
Hydra({
  mode = 'n',
  body = '<Leader>w.',
  heads = window_hydra_heads,
  config = {
    hint = {
      type = 'window',
      show_name = false,
    },
    timeout = 5000,
    color = 'red',
  },
})

-- split
vim.keymap.set('n', '<Leader>wS', '<C-w>s', { desc = 'Horizontal split and focus new window' })
vim.keymap.set('n', '<Leader>wV', '<C-w>v', { desc = 'Vertical split and focus new window' })
vim.keymap.set('n', '<Leader>ws', '<C-w>s', { desc = 'Horizontal split and focus new window' }) -- 本家が微妙
vim.keymap.set('n', '<Leader>wv', '<C-w>v', { desc = 'Vertical split and focus new window' }) -- 本家が微妙

-- focus
vim.keymap.set('n', '<Leader>1', '1<C-w>w', { desc = 'Go to window #1' })
vim.keymap.set('n', '<Leader>2', '2<C-w>w', { desc = 'Go to window #2' })
vim.keymap.set('n', '<Leader>3', '3<C-w>w', { desc = 'Go to window #3' })
vim.keymap.set('n', '<Leader>4', '4<C-w>w', { desc = 'Go to window #4' })
vim.keymap.set('n', '<Leader>5', '5<C-w>w', { desc = 'Go to window #5' })
vim.keymap.set('n', '<Leader>6', '6<C-w>w', { desc = 'Go to window #6' })
vim.keymap.set('n', '<Leader>7', '7<C-w>w', { desc = 'Go to window #7' })
vim.keymap.set('n', '<Leader>8', '8<C-w>w', { desc = 'Go to window #8' })
vim.keymap.set('n', '<Leader>9', '9<C-w>w', { desc = 'Go to window #9' })
vim.keymap.set('n', '<Leader>ww', '<C-w>w', { desc = 'Focus other window' })
vim.keymap.set('n', '<Leader>wh', '<C-w>h', { desc = 'Go to window on the left' })
vim.keymap.set('n', '<Leader>wj', '<C-w>j', { desc = 'Go to window below' })
vim.keymap.set('n', '<Leader>wk', '<C-w>k', { desc = 'Go to window above' })
vim.keymap.set('n', '<Leader>wl', '<C-w>l', { desc = 'Go to window on the right' })

-- move
vim.keymap.set('n', '<Leader>wH', '<C-w>H', { desc = 'Move window to the left' })
vim.keymap.set('n', '<Leader>wJ', '<C-w>J', { desc = 'Move window to the bottom' })
vim.keymap.set('n', '<Leader>wK', '<C-w>K', { desc = 'Move window to the top' })
vim.keymap.set('n', '<Leader>wL', '<C-w>L', { desc = 'Move window to the right' })
vim.keymap.set('n', '<Leader>wr', '<C-w>r', { desc = 'Rotate windows forward' })
vim.keymap.set('n', '<Leader>wR', '<C-w>R', { desc = 'Rotate windows backward' })

-- resize
vim.keymap.set('n', '<Leader>w[', '<Leader>w.[', { desc = 'Shrink window horizontally', remap = true })
vim.keymap.set('n', '<Leader>w]', '<Leader>w.]', { desc = 'Enlarge window horizontally', remap = true })
vim.keymap.set('n', '<Leader>w{', '<Leader>w.{', { desc = 'Shrink window vertically', remap = true })
vim.keymap.set('n', '<Leader>w}', '<Leader>w.}', { desc = 'Enlarge window vertically', remap = true })
vim.keymap.set('n', '<Leader>w=', '<C-w>=', { desc = 'Balance split windows' })

-- delete
vim.keymap.set('n', '<Leader>wd', '<Cmd>close!<CR>', { desc = 'Delete a window' })
vim.keymap.set('n', '<Leader>wm', function() require('snacks.zen').zoom() end, { desc = 'Delete other windows' })
vim.keymap.set('n', '<Leader>wx', '<Cmd>bd<CR>', { desc = 'Delete a window and its current buffer' })
