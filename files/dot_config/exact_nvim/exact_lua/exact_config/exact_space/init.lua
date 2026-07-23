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
vim.keymap.set('n', '<Leader>qq', '<Cmd>qa<CR>', { desc = 'Quit Neovim' })
vim.keymap.set('n', '<Leader>qQ', '<Cmd>qa!<CR>', { desc = 'Quit Neovim, lose all unsaved changes' })
vim.keymap.set('n', '<Leader>qs', '<Cmd>wqa<CR>', { desc = 'Save the buffers, quit Neovim' })

require((...) .. '.window')
require((...) .. '.buffer')
require((...) .. '.toggle')
require((...) .. '.file')
require((...) .. '.project')
require((...) .. '.search')
require((...) .. '.jump')
require((...) .. '.git')
require((...) .. '.comment')

