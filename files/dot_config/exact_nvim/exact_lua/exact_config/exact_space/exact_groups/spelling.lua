require('which-key').add({ { '<Leader>S', group = 'Spelling' } })

local checker = require('config.spellcheck')

vim.keymap.set('n', '<Leader>Sn', function() checker.jump('next') end, { desc = 'Jump to next spell error' })
vim.keymap.set('n', '<Leader>Sp', function() checker.jump('prev') end, { desc = 'Jump to previous spell error' }) -- 本家にはない
vim.keymap.set('n', '<Leader>SN', '<Leader>Sp', { desc = 'Jump to previous spell error', remap = true }) -- 本家にはない

require('config.hydra').create({
  name = 'Spelling',
  body = '<Leader>S.',
  heads = {
    { 'n', '<Leader>Sn', { desc = 'Jump to next spell error', remap = true } },
    { 't', checker.toggle, { desc = 'Toggle spell check' } },
    { 'Q', checker.disable, { desc = 'Quite transient state and disable spell check', exit = true } },
    { 'p', '<Leader>Sp', { desc = 'Jump to previous spell error', remap = true } }, -- 本家にはない
    { 'N', '<Leader>SN', { desc = 'Jump to previous spell error', remap = true } }, -- 本家にはない
    { 'z', require('config.keymap_actions').recenter, { desc = 'Recenter buffer in window' } }, -- 本家にはない
  },
})
