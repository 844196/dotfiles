vim.api.nvim_set_var('mapleader', ' ')
vim.api.nvim_set_var('maplocalleader', ',')

require('which-key').setup({
  delay = 0,
  spec = {
    { '<Leader>m', group = 'Major' },
    { '<Leader>m=', group = 'Format' },
    { '<Leader>ma', group = 'Action' },
    { '<Leader>mr', group = 'Refactor' },
    { '<Leader>mg', group = 'Peek' },
    { '<Leader>mG', group = 'Goto' },
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

---@param buf integer
---@param mode string
---@param lhs string
---@return boolean
local function is_remapped(buf, mode, lhs)
  for _, remap in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
    if remap.lhs == vim.fn.keytrans(vim.keycode(lhs)) then
      return true
    end
  end
  return false
end

---@class RemapOpts : vim.keymap.set.Opts
---@field lsp vim.lsp.get_clients.Filter

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts RemapOpts
local function remap(mode, lhs, rhs, opts)
  if type(mode) == 'table' then
    for _, m in ipairs(mode) do
      remap(m, lhs, rhs, opts)
    end
    return
  end

  local lsp = opts.lsp
  opts.lsp = nil

  require('snacks.util').lsp.on(lsp, function(buf)
    if not is_remapped(buf, mode, lhs) then
      vim.keymap.set(mode, lhs, rhs, vim.tbl_deep_extend('force', opts or {}, { buf = buf }))
    end
  end)
end

local telescope = require('telescope.builtin')

remap({ 'n', 'x' }, '<Leader>m==', vim.lsp.buf.format, {
  desc = 'Format region or buffer',
  lsp = { method = 'textDocument/formatting' },
})

remap({ 'n', 'x' }, '<Leader>maa', vim.lsp.buf.code_action, {
  desc = 'Execute code action',
  lsp = { method = 'textDocument/codeAction' },
})

remap('n', '<Leader>mrr', vim.lsp.buf.rename, {
  desc = 'Rename symbol',
  lsp = { method = 'textDocument/rename' },
})

remap('n', '<Leader>mgM', telescope.lsp_document_symbols, {
  desc = 'Browse symbols in buffer',
  lsp = { method = 'textDocument/documentSymbol' },
})
remap('n', '<Leader>mgs', telescope.lsp_workspace_symbols, {
  desc = 'Find symbol in project',
  lsp = { method = 'workspace/symbol' },
})
remap('n', '<Leader>mgd', telescope.lsp_definitions, {
  desc = 'Peek definition',
  lsp = { method = 'textDocument/definition' },
})
remap('n', '<Leader>mgt', telescope.lsp_type_definitions, {
  desc = 'Peek type definition',
  lsp = { method = 'textDocument/typeDefinition' },
})
remap('n', '<Leader>mgi', telescope.lsp_implementations, {
  desc = 'Peek implementations',
  lsp = { method = 'textDocument/implementation' },
})
remap('n', '<Leader>mgr', telescope.lsp_references, {
  desc = 'Peek references',
  lsp = { method = 'textDocument/references' },
})

remap('n', '<Leader>mGd', vim.lsp.buf.definition, {
  desc = 'Goto definition',
  lsp = { method = 'textDocument/definition' },
})
remap('n', '<Leader>mGt', vim.lsp.buf.type_definition, {
  desc = 'Goto type definition',
  lsp = { method = 'textDocument/typeDefinition' },
})
remap('n', '<Leader>mGi', vim.lsp.buf.implementation, {
  desc = 'Goto implementations',
  lsp = { method = 'textDocument/implementation' },
})
remap('n', '<Leader>mGr', vim.lsp.buf.references, {
  desc = 'Goto references',
  lsp = { method = 'textDocument/references' },
})
