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
  icons = {
    rules = false,
  },
  show_help = false,
})

local group = (...) .. '.groups'
local dir = 'lua/' .. group:gsub('%.', '/')

local names = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file(dir .. '/*.lua', true)) do
  names[#names + 1] = vim.fn.fnamemodify(path, ':t:r')
end
table.sort(names)

for _, name in ipairs(names) do
  require(group .. '.' .. name)
end
