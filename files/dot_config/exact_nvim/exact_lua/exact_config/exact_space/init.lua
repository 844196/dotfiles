vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_var('maplocalleader', ',')

require('which-key').setup({
  delay = 0,
  spec = {
    { '<Leader>m', group = 'Major' },
    { '<LocalLeader>', mode = { 'n', 'v' }, proxy = '<Leader>m' },
  },
  triggers = {
    { '<Leader>', mode = { 'n', 'v' } },
  },
  plugins = {
    marks = false,
    registers = false,
    spelling = { enabled = false }
  },
  replace = {
    key = {
      { '<Space>', 'SPC' },
    },
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

---@param bufnr integer
---@param mode string | string[]
local function map_unless_taken(bufnr, mode, lhs, rhs, desc)
  local modes = {}
  if type(mode) == 'string' then
    modes = { mode }
  else
    modes = mode
  end

  for _, m in ipairs(modes) do
    local found = false
    for _, map in ipairs(vim.api.nvim_buf_get_keymap(bufnr, m)) do
      if map.lhs == vim.fn.keytrans(vim.keycode(lhs)) then
        found = true
        break
      end
    end

    if not found then
      vim.keymap.set(mode, lhs, rhs, { buf = bufnr, desc = desc })
    end
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(evt)
    local cl = vim.lsp.get_client_by_id(evt.data.client_id)
    if assert(cl):supports_method('textDocument/formatting') then
      map_unless_taken(evt.buf, { 'n', 'x' }, '<Leader>m==', vim.lsp.buf.format, 'Format region or buffer')
      map_unless_taken(evt.buf, 'n', '<Leader>m=b', vim.lsp.buf.format, 'Format buffer')
    end
  end,
})
