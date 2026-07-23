require('which-key').add({ { '<Leader>q', group = 'Quit' } })

vim.keymap.set('n', '<Leader>qq', '<Cmd>qa<CR>', { desc = 'Quit Neovim' })
vim.keymap.set('n', '<Leader>qQ', '<Cmd>qa!<CR>', { desc = 'Quit Neovim, lose all unsaved changes' })
vim.keymap.set('n', '<Leader>qs', '<Cmd>wqa<CR>', { desc = 'Save the buffers, quit Neovim' })

local function restart_with_session()
  local tpl = vim.fs.joinpath(vim.uv.os_tmpdir(), 'nvim-restart-XXXXXX')
  local session_dir = assert(vim.uv.fs_mkdtemp(tpl))
  local path = vim.fs.joinpath(session_dir, 'session.vim')
  local escaped = vim.fn.fnameescape(path)
  vim.cmd('mksession! ' .. escaped)
  vim.cmd('restart source ' .. escaped)
end

vim.keymap.set('n', '<Leader>qr', function() restart_with_session() end, { desc = 'Restart Neovim' })
vim.keymap.set('n', '<Leader>qR', '<Cmd>restart<CR>', { desc = 'Restart Neovim without restoring session' })
