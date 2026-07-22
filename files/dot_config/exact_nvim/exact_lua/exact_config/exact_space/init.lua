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

-- ex
vim.keymap.set({ 'n', 'v' }, '<Leader><Leader>', ':')

-- help
vim.keymap.set('n', '<Leader>h<Leader>', ':h ')

-- quit
vim.keymap.set('n', '<Leader>qq', '<Cmd>qa<CR>')
vim.keymap.set('n', '<Leader>qs', '<Cmd>wq<CR>')

require((...) .. '.window')
require((...) .. '.buffer')
require((...) .. '.toggle')
require((...) .. '.file')
require((...) .. '.project')
require((...) .. '.search')
require((...) .. '.jump')
require((...) .. '.git')

