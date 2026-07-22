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
vim.keymap.set('n', '<Leader>wh', '<C-w>h')
vim.keymap.set('n', '<Leader>wj', '<C-w>j')
vim.keymap.set('n', '<Leader>wk', '<C-w>k')
vim.keymap.set('n', '<Leader>wl', '<C-w>l')
vim.keymap.set('n', '<Leader>wH', '<C-w>H')
vim.keymap.set('n', '<Leader>wJ', '<C-w>J')
vim.keymap.set('n', '<Leader>wK', '<C-w>K')
vim.keymap.set('n', '<Leader>wL', '<C-w>L')
vim.keymap.set('n', '<Leader>w=', '<C-w>=')
vim.keymap.set('n', '<Leader>wm', '<Cmd>wincmd _ | wincmd |<CR>')
vim.keymap.set('n', '<Leader>wv', '<C-w>v')
vim.keymap.set('n', '<Leader>ws', '<C-w>s')
vim.keymap.set('n', '<Leader>wd', '<Cmd>close!<CR>', { desc = 'Delete a window' })
vim.keymap.set('n', '<Leader>wD', '<Cmd>only<CR>', { desc = 'Delete another window' })
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
