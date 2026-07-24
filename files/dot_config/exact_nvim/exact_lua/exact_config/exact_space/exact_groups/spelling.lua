require('which-key').add({ { '<Leader>S', group = 'Spelling' } })

local codebook = require('config.space.codebook')

vim.keymap.set('n', '<Leader>Sn', function() codebook.jump('next') end, { desc = 'Jump to next spell error' })
vim.keymap.set('n', '<Leader>Sp', function() codebook.jump('prev') end, { desc = 'Jump to previous spell error' }) -- 本家にはない
vim.keymap.set('n', '<Leader>SN', '<Leader>Sp', { desc = 'Jump to previous spell error', remap = true }) -- 本家にはない

require('config.space.hydra').create({
  body = '<Leader>S.',
  heads = {
    { 'n', '<Leader>Sn', { desc = 'Jump to next spell error', remap = true } },
    { 't', codebook.toggle, { desc = 'Toggle spell check' } },
    { 'Q', codebook.disable, { desc = 'Quite transient state and disable spell check', exit = true } },
    { 'p', '<Leader>Sp', { desc = 'Jump to previous spell error', remap = true } }, -- 本家にはない
    { 'N', '<Leader>SN', { desc = 'Jump to previous spell error', remap = true } }, -- 本家にはない
    { 'z', require('config.space.recenter'), { desc = 'Recenter buffer in window' } }, -- 本家にはない
  },
})
