local M = {}

function M.restart_with_session()
  local tpl = vim.fs.joinpath(vim.uv.os_tmpdir(), 'nvim-restart-XXXXXX')
  local session_dir = assert(vim.uv.fs_mkdtemp(tpl))
  local path = vim.fs.joinpath(session_dir, 'session.vim')
  local escaped = vim.fn.fnameescape(path)
  vim.cmd('mksession! ' .. escaped)
  vim.cmd('restart source ' .. escaped)
end

return M
