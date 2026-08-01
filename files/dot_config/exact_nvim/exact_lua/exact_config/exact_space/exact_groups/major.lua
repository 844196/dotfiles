require('which-key').add({
  { '<Leader>m', group = 'Major' },
  { '<Leader>mT', group = 'Toggle' },
  { '<Leader>m=', group = 'Format' },
  { '<Leader>ma', group = 'Action' },
  { '<Leader>mr', group = 'Refactor' },
  { '<Leader>mg', group = 'Peek' },
  { '<Leader>mG', group = 'Goto' },
})

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

local telescope_builtin = require('telescope.builtin')

remap({ 'n', 'x' }, '<Leader>m==', vim.lsp.buf.format, {
  desc = 'Format region or buffer',
  lsp = { method = 'textDocument/formatting' },
})

remap({ 'n', 'x' }, '<Leader>maa', function()
  require("tiny-code-action").code_action({})
end, {
  desc = 'Execute code action',
  lsp = { method = 'textDocument/codeAction' },
})

remap('n', '<Leader>mrr', vim.lsp.buf.rename, {
  desc = 'Rename symbol',
  lsp = { method = 'textDocument/rename' },
})

remap('n', '<Leader>mgM', telescope_builtin.lsp_document_symbols, {
  desc = 'Browse symbols in buffer',
  lsp = { method = 'textDocument/documentSymbol' },
})
remap('n', '<Leader>mgs', telescope_builtin.lsp_workspace_symbols, {
  desc = 'Find symbol in project',
  lsp = { method = 'workspace/symbol' },
})
remap('n', '<Leader>mgd', telescope_builtin.lsp_definitions, {
  desc = 'Peek definition',
  lsp = { method = 'textDocument/definition' },
})
remap('n', '<Leader>mgt', telescope_builtin.lsp_type_definitions, {
  desc = 'Peek type definition',
  lsp = { method = 'textDocument/typeDefinition' },
})
remap('n', '<Leader>mgi', telescope_builtin.lsp_implementations, {
  desc = 'Peek implementations',
  lsp = { method = 'textDocument/implementation' },
})
remap('n', '<Leader>mgr', telescope_builtin.lsp_references, {
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
