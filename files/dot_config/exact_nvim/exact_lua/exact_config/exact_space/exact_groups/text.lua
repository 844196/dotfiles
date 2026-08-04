require('which-key').add({ { '<Leader>x', group = 'Text' } })

vim.keymap.set({ 'n', 'x' }, '<Leader>xo', require('config.keymap_actions').open, { desc = 'Open' })

-- case
local function case(t)
  return function()
    require('textcase')[vim.fn.mode() == 'v' and 'operator' or 'current_word'](t)
  end
end
vim.keymap.set({ 'n', 'x' }, '<Leader>xic', case('to_camel_case'), { desc = 'lowerCamelCase' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xiC', case('to_pascal_case'), { desc = 'UpperCamelCase' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xi-', case('to_dash_case'), { desc = 'kebab-case' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xik', '<Leader>xi-', { desc = 'kebab-case', remap = true })
vim.keymap.set({ 'n', 'x' }, '<Leader>xi_', case('to_snake_case'), { desc = 'snake_case' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xiu', '<Leader>xi_', { desc = 'snake_case', remap = true })
vim.keymap.set({ 'n', 'x' }, '<Leader>xiU', case('to_constant_case'), { desc = 'CONSTANT_CASE' })
