require('which-key').add({ { '<Leader>g', group = 'Git' } })

local gitsigns = require('gitsigns')

local function nav_hunk(dir)
  local before = vim.fn.line('.')
  gitsigns.nav_hunk(
    dir,
    ---@diagnostic disable-next-line: missing-fields プラグイン側の型定義がおかしい
    { target = 'all', wrap = false },
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
    'c',
    function() require('neogit').open({ 'commit' }) end,
    { exit = true, desc = 'Open Neogit commit popup' },
  },
  {
    'C',
    require('config.neogit').claude_commit,
    { exit = true, desc = 'Claude Commit' },
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
  {
    'z',
    require('config.keymap_actions').recenter,
    { desc = 'Recenter buffer in window' },
  },
}

-- red は非 head キーを貫通させない代わりに表示切り替えが遅く分かりづらい。
-- pink は表示は速いが非 head キーが貫通してしまう。
-- 折衷案として head に使っていないアルファベット1文字キーにはパススルー用の head を明示的に張る。
-- https://github.com/nvimtools/hydra.nvim/wiki/Git#red-amaranth-and-teal-colors
local hydra = require('config.hydra')
do
  local used_head_keys = {}
  for _, head in ipairs(git_hydra_heads) do
    used_head_keys[head[1]] = true
  end
  for _, head in ipairs(hydra.exit_heads) do
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

hydra.create({
  body = '<Leader>g.',
  heads = git_hydra_heads,
  color = 'pink',
})

vim.keymap.set('n', '<Leader>gs', '<Cmd>Neogit<CR>', { desc = 'Open a neogit' })
vim.keymap.set('n', '<Leader>gm', '<Cmd>Neogit<CR>', { desc = 'Open a neogit' })
vim.keymap.set('n', '<Leader>gS', gitsigns.stage_buffer, { desc = 'Stage current file' })
vim.keymap.set('n', '<Leader>gU', gitsigns.reset_buffer_index, { desc = 'Unstage current file' })

vim.keymap.set('n', '<Leader>gff', function()
  require('telescope.builtin').git_status(require('config.telescope.themes').get_ivy_hermit())
end, { desc = 'Uncommitted files' })
vim.keymap.set('n', '<Leader>gfd', '<Cmd>CodeDiff file HEAD<CR>', { desc = 'Buffer diff' })
