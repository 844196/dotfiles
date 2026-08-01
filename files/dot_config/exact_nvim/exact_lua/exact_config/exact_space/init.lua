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
    if cl == nil or cl.name == 'codebook' then
      return
    end

    if cl:supports_method('textDocument/formatting') then
      map_unless_taken(evt.buf, { 'n', 'x' }, '<Leader>m==', vim.lsp.buf.format, 'Format region or buffer')
    end

    if cl:supports_method('textDocument/codeAction') then
      map_unless_taken(evt.buf, 'n', '<Leader>maa', vim.lsp.buf.code_action, 'Execute code action')
    end

    if cl:supports_method('textDocument/rename') then
      map_unless_taken(evt.buf, 'n', '<Leader>mrr', vim.lsp.buf.rename, 'Rename symbol')
    end

    if cl:supports_method('textDocument/documentSymbol') then
      map_unless_taken(evt.buf, 'n', '<Leader>mgM', require('telescope.builtin').lsp_document_symbols, 'Browse file symbols')
    end

    if cl:supports_method('textDocument/definition') then
      map_unless_taken(evt.buf, 'n', '<Leader>mgd', require('telescope.builtin').lsp_definitions, 'Peek definition')
      map_unless_taken(evt.buf, 'n', '<Leader>mGd', vim.lsp.buf.definition, 'Goto definition')
    end

    if cl:supports_method('textDocument/typeDefinition') then
      map_unless_taken(evt.buf, 'n', '<Leader>mgt', require('telescope.builtin').lsp_type_definitions, 'Peek type definition')
      map_unless_taken(evt.buf, 'n', '<Leader>mGt', vim.lsp.buf.type_definition, 'Goto type definition')
    end

    if cl:supports_method('textDocument/implementation') then
      map_unless_taken(evt.buf, 'n', '<Leader>mgi', require('telescope.builtin').lsp_implementations, 'Peek implementations')
      map_unless_taken(evt.buf, 'n', '<Leader>mGi', vim.lsp.buf.implementation, 'Goto implementations')
    end

    if cl:supports_method('textDocument/references') then
      map_unless_taken(evt.buf, 'n', '<Leader>mgr', require('telescope.builtin').lsp_references, 'Peek references')
      map_unless_taken(evt.buf, 'n', '<Leader>mGr', vim.lsp.buf.references, 'Goto references')
    end

    if cl:supports_method('workspace/symbol') then
      map_unless_taken(evt.buf, 'n', '<Leader>mgs', require('telescope.builtin').lsp_workspace_symbols, 'Find symbol in project')
    end
  end,
})
