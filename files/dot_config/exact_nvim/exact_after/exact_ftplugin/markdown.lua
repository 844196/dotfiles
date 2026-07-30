require('render-markdown').setup({
  enabled = false,
  completions = {
    lsp = { enabled = true },
  },
})

local group = vim.api.nvim_create_augroup('markdown_layer', { clear = false })

---@class MoResult
---@field url string
---@field files { name: string, path: string, url: string }[]

---@return string
local function mo_target()
  return vim.fs.basename(assert(vim.uv.cwd()))
end

local function open_by_mo()
  if vim.b.mo_target ~= nil then
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path == '' or vim.fn.filereadable(path) == 0 then
    vim.notify('Must be visiting a file', vim.log.levels.ERROR)
    return
  end

  local target = mo_target()
  local res = vim.system({ 'mo', '--json', '--no-open', '--target', target, path }, { text = true }):wait(5000)
  if res.code ~= 0 then
    vim.notify('mo: ' .. res.stderr, vim.log.levels.ERROR)
    return
  end

  local ok, decoded = pcall(vim.json.decode, res.stdout)
  if not ok or type(decoded) ~= 'table' or not vim.tbl_get(decoded, 'files', 1, 'url') then
    vim.notify('mo: unexpected output: ' .. res.stdout, vim.log.levels.ERROR)
    return
  end
  ---@cast decoded MoResult

  local chroma = vim.system({ 'chroma', decoded.files[1].url }, { text = true }):wait(5000)
  if chroma.code ~= 0 then
    vim.notify('chroma: ' .. chroma.stderr, vim.log.levels.ERROR)
    return
  end

  -- close 時に cwd が変わっていても正しいグループを狙えるように記録
  vim.b.mo_target = target
end

---@param bufnr integer
local function close_by_mo(bufnr)
  local target = vim.b[bufnr].mo_target
  if not target then
    return -- mo で開いていないバッファ
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    return
  end

  -- 失敗しても気にしない。nvim 終了時に殺されないよう detach する
  vim.system({ 'mo', '--close', '--target', target, path }, { detach = true })
end

vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd('BufDelete', {
  group = group,
  buffer = 0,
  callback = function(evt)
    close_by_mo(evt.buf)
  end,
})

-- VimLeavePre はバッファローカルにできないので一度だけ登録する
vim.api.nvim_clear_autocmds({ group = group, event = 'VimLeavePre' })
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  callback = function()
    -- :qa では BufDelete が飛ばないのでここで回収する
    vim.iter(vim.api.nvim_list_bufs()):each(close_by_mo)
  end,
})

vim.keymap.set('n', '<LocalLeader>co', open_by_mo, { desc = 'Preview by mo', buf = 0 })
vim.keymap.set('n', '<LocalLeader>Tm', require('render-markdown').buf_toggle, { desc = 'Toggle markup hiding', buf = 0 })
