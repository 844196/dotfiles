require('which-key').add({ { '<Leader>r', group = 'Resume' } })

vim.keymap.set('n', '<Leader>rl', function()
  require('telescope.builtin').resume()
end, { desc = 'Resume last telescope picker' })
