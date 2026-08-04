require('which-key').add({
  { '<Leader>m', group = 'Major' },
  { '<Leader>mT', group = 'Toggle' },
  { '<Leader>m=', group = 'Format' },
  { '<Leader>ma', group = 'Action' },
  { '<Leader>mr', group = 'Refactor' },
  { '<Leader>mg', group = 'Peek' },
  { '<Leader>mG', group = 'Goto' },
})

local telescope_builtin = require('telescope.builtin')

vim.keymap.set({ 'n', 'x' }, '<Leader>m==', vim.lsp.buf.format, {
  desc = 'Format region or buffer',
})

vim.keymap.set({ 'n', 'x' }, '<Leader>maa', function()
  require("tiny-code-action").code_action({})
end, {
  desc = 'Execute code action',
})

vim.keymap.set('n', '<Leader>mrr', vim.lsp.buf.rename, {
  desc = 'Rename symbol',
})

local get_ivy_hermit = require('config.telescope.themes').get_ivy_hermit

vim.keymap.set('n', '<Leader>mgM', function()
  telescope_builtin.lsp_document_symbols(get_ivy_hermit())
end, {
  desc = 'Browse symbols in buffer',
})
vim.keymap.set({ 'n', 'x' }, '<Leader>mgs', function()
  local cursor = require('config.cursor')
  telescope_builtin.lsp_workspace_symbols(get_ivy_hermit({ default_text = cursor.region_or(cursor.cword) }))
end, {
  desc = 'Find symbol in project',
})

local function get_peek(opts)
  return require('config.telescope.themes').get_peek(vim.tbl_deep_extend('force', { jump_type = 'never', layout_config = { height = 0.2 } }, opts or {}))
end

vim.keymap.set('n', '<Leader>mgd', function()
  telescope_builtin.lsp_definitions(get_peek())
end, {
  desc = 'Peek definition',
})
vim.keymap.set('n', '<Leader>mgt', function()
  telescope_builtin.lsp_type_definitions(get_peek())
end, {
  desc = 'Peek type definition',
})
vim.keymap.set('n', '<Leader>mgi', function()
  telescope_builtin.lsp_implementations(get_peek())
end, {
  desc = 'Peek implementations',
})
vim.keymap.set('n', '<Leader>mgr', function()
  telescope_builtin.lsp_references(get_peek())
end, {
  desc = 'Peek references',
})

vim.keymap.set('n', '<Leader>mGd', vim.lsp.buf.definition, {
  desc = 'Goto definition',
})
vim.keymap.set('n', '<Leader>mGt', vim.lsp.buf.type_definition, {
  desc = 'Goto type definition',
})
vim.keymap.set('n', '<Leader>mGi', vim.lsp.buf.implementation, {
  desc = 'Goto implementations',
})
vim.keymap.set('n', '<Leader>mGr', vim.lsp.buf.references, {
  desc = 'Goto references',
})
