vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_var('maplocalleader', ',')
require('which-key').setup({
  delay = 0,
  triggers = {
    { '<Leader>', mode = { 'n', 'v' } },
    { '<LocalLeader>', mode = { 'n', 'v' } },
  },
  plugins = {
    marks = false,
    registers = false,
    spelling = { enabled = false }
  },
})

local Hydra = require('hydra')

vim.keymap.set({ 'n', 'v' }, '<Leader><Leader>', ':')
vim.keymap.set('n', '<Leader>h<Leader>', ':h ')
vim.keymap.set('n', '<Leader>qq', '<Cmd>qa<CR>')
vim.keymap.set('n', '<Leader>qs', '<Cmd>wq<CR>')

local window_hydra_heads = {
  { '<Esc>', nil, { exit = true, desc = false } },
  { 'q', nil, { exit = true, desc = false } },

  -- split
  { 's', '<C-w>s', { desc = 'Horizontal split' } },
  { 'v', '<C-w>v', { desc = 'Vertical split' } },

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
  { '_', '<C-w>|', {
    -- `_` をヘッドキーに使うとヒント描画がクラッシュしてしまう
    -- https://github.com/anuvyklack/hydra.nvim/issues/14
    desc = false,
  } },
  { '{', '<C-w>-', { desc = 'Shrink window vertically' } },
  { '}', '<C-w>+', { desc = 'Enlarge window vertically' } },
  { '|', '<C-w>_', { desc = 'Maximize window vertically' } },
  { 'm', '<C-w>|<C-w>_', { desc = 'Maximize a window' } },
  { '=', '<C-w>=', { desc = 'Balance split windows' } },

  -- delete
  { 'd', '<Cmd>close!<CR>', { desc = 'Delete window' } },
  { 'D', '<Cmd>only<CR>', { desc = 'Delete other windows' } },
  { 'x', '<Cmd>bd<CR>', { desc = 'Delete window and kill buffer' } },
}
Hydra({
  mode = 'n',
  body = '<Leader>w.',
  heads = window_hydra_heads,
  config = {
    hint = {
      type = 'window',
      show_name = false,
    },
    timeout = 30000,
    color = 'red',
  },
})

-- split
vim.keymap.set('n', '<Leader>ws', '<C-w>s', { desc = 'Horizontal split' })
vim.keymap.set('n', '<Leader>wv', '<C-w>v', { desc = 'Vertical split' })

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
vim.keymap.set('n', '<Leader>w_', '<C-w>|', { desc = 'Maximize window horizontally' })
vim.keymap.set('n', '<Leader>w{', '<Leader>w.{', { desc = 'Shrink window vertically', remap = true })
vim.keymap.set('n', '<Leader>w}', '<Leader>w.}', { desc = 'Enlarge window vertically', remap = true })
vim.keymap.set('n', '<Leader>w|', '<C-w>_', { desc = 'Maximize window vertically' })
vim.keymap.set('n', '<Leader>wm', '<C-w>|<C-w>_', { desc = 'Maximize a window' })
vim.keymap.set('n', '<Leader>w=', '<C-w>=', { desc = 'Balance split windows' })

-- delete
vim.keymap.set('n', '<Leader>wd', '<Cmd>close!<CR>', { desc = 'Delete a window' })
vim.keymap.set('n', '<Leader>wD', '<Cmd>only<CR>', { desc = 'Delete other windows' })
vim.keymap.set('n', '<Leader>wx', '<Cmd>bd<CR>', { desc = 'Delete a window and its current buffer' })

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
vim.keymap.set('n', '<Leader>bNh', '<Cmd>leftabove vnew<CR>', { desc = 'Create new empty buffer in a new window on the left' })
vim.keymap.set('n', '<Leader>bNj', '<Cmd>belowright new<CR>', { desc = 'Create new empty buffer in a new window at the bottom' })
vim.keymap.set('n', '<Leader>bNk', '<Cmd>aboveleft new<CR>', { desc = 'Create new empty buffer in a new window above' })
vim.keymap.set('n', '<Leader>bNl', '<Cmd>belowright vnew<CR>', { desc = 'Create new empty buffer in a new window below' })
vim.keymap.set('n', '<Leader>bNn', '<Cmd>enew<CR>', { desc = 'Create new empty buffer in current window' })
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
vim.keymap.set('n', '<Leader>tn', '<Cmd>setlocal number!<CR>')
vim.keymap.set('n', '<Leader>thh', function()
  vim.o.cursorlineopt = vim.o.cursorlineopt == 'number' and 'both' or 'number'
end)
vim.keymap.set('n', '<Leader>tf', function()
  vim.o.colorcolumn = vim.o.colorcolumn ~= '120' and '120' or ''
end)
vim.keymap.set('n', '<Leader>fj', '<Cmd>Oil<CR>', { desc = 'Jump to the current buffer file in oil' })
vim.keymap.set('n', '<Leader>fl', ':<C-u>set ft=')
vim.keymap.set('n', '<Leader>fyn', '<Cmd>let @+ = expand("%:.")<CR>', { desc = 'Copy current file name with extension' })
vim.keymap.set('n', '<Leader>fyy', '<Cmd>let @+ = expand("%:p")<CR>', { desc = 'Copy current file absolute path' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyl', function()
  local from, to = vim.fn.line('v'), vim.fn.line('.')
  if vim.fn.mode() == 'V' and from ~= to then
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. math.min(from, to) .. '-' .. math.max(from, to))
  else
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. to)
  end
end, { desc = 'Copy current file absolute path with line number(s)' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyc', '<Cmd>let @+ = expand("%:p").":".line(".").":".col(".")<CR>', { desc = 'Copy current file absolute path with line and column number' })
vim.keymap.set('n', '<Leader>fyd', '<Cmd>let @+ = expand("%:p:h")<CR>', { desc = 'Copy current directory absolute path' })
vim.keymap.set('n', '<Leader>fei', function()
  local result = vim.system({ 'chezmoi', 'source-path', vim.env.MYVIMRC }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify('chezmoi source-path failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape((result.stdout:gsub('%s+$', ''))))
end, { desc = 'Open the all mighty init.lua' })
vim.keymap.set('n', '<Leader>fed', function()
  local result = vim.system({ 'chezmoi', 'source-path', vim.env.MYVIMRC }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify('chezmoi source-path failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end
  local source_path = result.stdout:gsub('%s+$', '')
  vim.cmd.Oil(vim.fn.fnameescape(vim.fs.dirname(source_path)))
end, { desc = 'Open the nvim dotfiles in oil' })
vim.keymap.set('n', '<Leader>feR', function()
  vim.cmd.tabnew()
  vim.fn.jobstart({ 'chezmoi', 'apply', vim.fs.dirname(vim.env.MYVIMRC) }, {
    term = true,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          vim.cmd.restart()
        end)
      end
    end,
  })
  vim.cmd.startinsert()
end, { desc = 'Resync the dotfiles with nvim' })
vim.keymap.set('n', '<Leader>pf', '<Cmd>Telescope find_files<CR>', { desc = 'Find file' })
vim.keymap.set('n', '<Leader>pD', '<Cmd>Oil .<CR>', { desc = 'Open project root in oil' })
vim.keymap.set('n', '<Leader>sp', '<Cmd>Telescope live_grep<CR>', { desc = 'Search in a project' })
vim.keymap.set('n', '<Leader>ss', '<Cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = 'Search in current file' })
vim.keymap.set('n', '<Leader>jb', '<C-o>zz', { desc = 'Go back to previous location' })
vim.keymap.set('n', '<Leader>jC', '`.zz', { desc = 'Go to last change' })

local gitsigns = require('gitsigns')

local function nav_hunk(dir)
  local before = vim.fn.line('.')
  gitsigns.nav_hunk(
    dir,
    ---@diagnostic disable-next-line: missing-fields プラグイン側の型定義がおかしい
    { target = 'all', navigation_message = false },
    function()
      if vim.fn.line('.') ~= before then
        vim.cmd('normal! zz')
      end
    end
  )
end

local git_hydra_heads = {
  {
    'n',
    function() nav_hunk('next') end,
    { desc = 'Next hunk' },
  },
  {
    'N',
    function() nav_hunk('prev') end,
    { desc = 'Previous hunk' },
  },
  {
    'p',
    function() nav_hunk('prev') end,
    { desc = 'Previous hunk' },
  },
  {
    'r',
    gitsigns.reset_hunk,
    { desc = 'Revert hunk' },
  },
  {
    's',
    gitsigns.stage_hunk,
    { desc = 'Stage hunk' },
  },
  {
    'w',
    gitsigns.stage_buffer,
    { desc = 'Stage file' },
  },
  {
    'u',
    gitsigns.reset_buffer_index,
    { desc = 'Unstage file' },
  },
  { '<Esc>', nil, { exit = true, desc = false } },
  { 'q', nil, { exit = true, desc = false } },
}

-- red は非 head キーを貫通させない代わりに表示切り替えが遅く分かりづらい。
-- pink は表示は速いが非 head キーが貫通してしまう。
-- 折衷案として head に使っていないアルファベット1文字キーにはパススルー用の head を明示的に張る。
-- https://github.com/nvimtools/hydra.nvim/wiki/Git#red-amaranth-and-teal-colors
do
  local used_head_keys = {}
  for _, head in ipairs(git_hydra_heads) do
    used_head_keys[head[1]] = true
  end
  for byte = string.byte('a'), string.byte('z') do
    local lower = string.char(byte)
    local upper = lower:upper()
    if not used_head_keys[lower] then
      table.insert(git_hydra_heads, { lower, lower, { exit = true, desc = false } })
    end
    if not used_head_keys[upper] then
      table.insert(git_hydra_heads, { upper, upper, { exit = true, desc = false } })
    end
  end
end

Hydra({
  mode = 'n',
  body = '<Leader>g.',
  heads = git_hydra_heads,
  config = {
    hint = {
      type = 'window',
      show_name = false,
    },
    timeout = 30000,
    color = 'pink',
  },
})
