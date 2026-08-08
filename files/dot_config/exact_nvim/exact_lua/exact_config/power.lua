local M = {}

---@param buf integer
local function is_disposable_buffer(buf)
  local filetype = vim.bo[buf].filetype
  if filetype == 'no-neck-pain' or filetype == 'qf' then
    return true
  end

  local name = vim.fn.bufname(buf)
  if name == '*scratch*' or name == '*messages*' or name == '*claude-prompt*' or string.match(name, '^Neogit') ~= nil then
    return true
  end

  return false
end

-- codediff.nvim は診断中の diff タブを `User CodeDiffOpen` / `User CodeDiffClose`
-- で通知してくれるため、名前パターンでの推測ではなくタブハンドルを直接追跡する。
-- diff を通常通り閉じた場合は CodeDiffClose で自動的に追跡から外れる。
local codediff_tabpages = {}
local codediff_augroup = vim.api.nvim_create_augroup('config.power.codediff', { clear = true })
vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeDiffOpen',
  group = codediff_augroup,
  callback = function(ev)
    local tabpage = ev.data and ev.data.tabpage
    if tabpage then
      codediff_tabpages[tabpage] = true
    end
  end,
})
vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeDiffClose',
  group = codediff_augroup,
  callback = function(ev)
    local tabpage = ev.data and ev.data.tabpage
    if tabpage then
      codediff_tabpages[tabpage] = nil
    end
  end,
})

-- render-markdown のプレビューウィンドウ (nofile の使い捨てバッファ) は
-- mksession でもウィンドウ構成として保存されてしまい、リスタート後に
-- 空のウィンドウとして残ってしまうため、セッション保存前に閉じておく。
local function close_render_markdown_previews()
  local ok, preview = pcall(require, 'render-markdown.core.preview')
  if not ok then
    return
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if preview.get(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

function M.restart_with_session()
  close_render_markdown_previews()
  -- codediff.nvim のタブは、上記バッファだけを削除すると diff 対象だった実ファイルの
  -- ウィンドウだけがそのタブに取り残される。実ファイルのバッファ自体は
  -- (mksession の badd で) 保持しつつ、単独タブとしては残らないようタブごと閉じる。
  for tabpage in pairs(codediff_tabpages) do
    if vim.api.nvim_tabpage_is_valid(tabpage) then
      if #vim.api.nvim_list_tabpages() == 1 then
        vim.cmd('tabnew')
      end
      vim.cmd(vim.api.nvim_tabpage_get_number(tabpage) .. 'tabclose!')
    end
    codediff_tabpages[tabpage] = nil
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_disposable_buffer(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  local tpl = vim.fs.joinpath(vim.uv.os_tmpdir(), 'nvim-restart-XXXXXX')
  local session_dir = assert(vim.uv.fs_mkdtemp(tpl))
  local path = vim.fs.joinpath(session_dir, 'session.vim')
  local escaped = vim.fn.fnameescape(path)
  vim.cmd('mksession! ' .. escaped)
  vim.cmd('restart source ' .. escaped)
end

return M
