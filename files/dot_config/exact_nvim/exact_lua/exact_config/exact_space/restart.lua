local M = {}

function M.restart_with_session()
  -- *scratch* / *Messages* は buftype=nofile の使い捨てバッファだが、
  -- mksession はウィンドウに表示中のバッファを badd + enew/file で復元しようとする。
  -- 名前が衝突すると buftype=nofile 等の設定を引き継げず modified=true になり、
  -- 復元後の :qa が E37/E162 でブロックされることがある。
  -- どちらも <Leader>bs / <Leader>bm で必要なときに作り直せるため、保存前に破棄する。
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.fn.bufname(buf)
    if name == [[*scratch*]] or name == '*Messages*' then vim.api.nvim_buf_delete(buf, { force = true }) end
  end

  local tpl = vim.fs.joinpath(vim.uv.os_tmpdir(), 'nvim-restart-XXXXXX')
  local session_dir = assert(vim.uv.fs_mkdtemp(tpl))
  local path = vim.fs.joinpath(session_dir, 'session.vim')
  local escaped = vim.fn.fnameescape(path)
  vim.cmd('mksession! ' .. escaped)
  vim.cmd('restart source ' .. escaped)
end

return M
