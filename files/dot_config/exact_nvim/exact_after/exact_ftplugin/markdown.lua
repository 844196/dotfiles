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

---@param url string
---@return integer|nil
local function port_from_url(url)
  local port = url:match(':(%d+)$')
  return port and tonumber(port) or nil
end

---@param files { name: string, path: string, url: string }[]
---@param path string
---@return string|nil
local function url_of_file(files, path)
  local abs_path = vim.fn.fnamemodify(path, ':p')
  for _, file in ipairs(files) do
    if vim.fn.fnamemodify(file.path, ':p') == abs_path then
      return file.url
    end
  end
  return nil
end

---@return string|nil mo が開いたファイルの url
local function open_by_mo()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' or vim.fn.filereadable(path) == 0 then
    vim.notify('Must be visiting a file', vim.log.levels.ERROR)
    return nil
  end

  local target = mo_target()
  local res = vim.system({ 'mo', '--json', '--no-open', '--target', target, path }, { text = true }):wait(5000)
  if res.code ~= 0 then
    vim.notify('mo: ' .. res.stderr, vim.log.levels.ERROR)
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, res.stdout)
  if not ok or type(decoded) ~= 'table' or type(decoded.files) ~= 'table' then
    vim.notify('mo: unexpected output: ' .. res.stdout, vim.log.levels.ERROR)
    return nil
  end
  ---@cast decoded MoResult

  -- files はこの呼び出しで開いたファイルだけでなく、セッション全体で開いている
  -- 全ファイルの一覧なので、自分が渡した path と一致するエントリを探す
  local file_url = url_of_file(decoded.files, path)
  if not file_url then
    vim.notify('mo: opened file not found in response: ' .. res.stdout, vim.log.levels.ERROR)
    return nil
  end

  -- close 時に cwd が変わっていても正しいグループを狙えるように記録
  vim.b.mo_target = target
  vim.b.mo_url = decoded.url

  return file_url
end

local function open_by_mo_and_chroma()
  local file_url = open_by_mo()
  if not file_url then
    return
  end

  local chroma = vim.system({ 'chroma', file_url }, { text = true }):wait(5000)
  if chroma.code ~= 0 then
    vim.notify('chroma: ' .. chroma.stderr, vim.log.levels.ERROR)
    return
  end
end

---@param bufnr integer
---@return string[]|nil
local function mo_close_cmd(bufnr)
  local target = vim.b[bufnr].mo_target
  if not target then
    return nil -- mo で開いていないバッファ
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then
    return nil
  end

  local cmd = { 'mo', '--close', '--target', target }
  local url = vim.b[bufnr].mo_url
  local port = url and port_from_url(url)
  if port then
    -- open 時と mo のデフォルトポートが変わっていても正しいサーバーを狙う
    vim.list_extend(cmd, { '-p', tostring(port) })
  end
  table.insert(cmd, path)
  return cmd
end

---@param bufnr integer
local function close_by_mo(bufnr)
  local cmd = mo_close_cmd(bufnr)
  if not cmd then
    return
  end

  -- 失敗しても気にしない。nvim 終了時に殺されないよう detach する
  vim.system(cmd, { detach = true })
end

---@param bufs integer[]
---@return string|nil, string|nil この nvim が mo で開いていた target と url。それぞれ 1 種類だけなら値、それ以外は nil
local function sole_own_mo_session(bufs)
  local targets, urls = {}, {}
  local target_count, url_count = 0, 0
  for _, buf in ipairs(bufs) do
    local target = vim.b[buf].mo_target
    local url = vim.b[buf].mo_url
    if target and not targets[target] then
      targets[target] = true
      target_count = target_count + 1
    end
    if url and not urls[url] then
      urls[url] = true
      url_count = url_count + 1
    end
  end
  if target_count ~= 1 or url_count ~= 1 then
    return nil, nil
  end
  return next(targets), next(urls)
end

---@param url string open_by_mo の応答に含まれていた mo サーバーの url
---@return string|nil url が指すサーバーの唯一のグループ名。稼働中でないかグループが 1 つでなければ nil
local function sole_running_mo_group(url)
  local res = vim.system({ 'mo', '--status', '--json' }, { text = true }):wait(5000)
  if res.code ~= 0 then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, res.stdout)
  if not ok or type(decoded) ~= 'table' then
    return nil
  end

  for _, server in ipairs(decoded) do
    if server.url == url then
      if server.status ~= 'running' then
        return nil
      end
      local groups = server.groups or {}
      if #groups ~= 1 then
        return nil
      end
      return groups[1].name
    end
  end
  return nil
end

---@param bufs integer[]
local function close_or_shutdown_mo(bufs)
  -- 同時に複数の nvim が mo を使うことはない前提: 自分が開いた target が
  -- 1 種類だけで、かつそれが mo 上の唯一のグループと一致するなら、
  -- 自分の分を閉じたうえで mo プロセスごと畳んでしまう (個別 close だけ
  -- では mo が残り続ける)。それ以外は今の nvim で開いていた分だけ閉じる。
  local own_target, own_url = sole_own_mo_session(bufs)
  local port = own_url and port_from_url(own_url)
  local should_shutdown = own_target ~= nil and port ~= nil and own_target == sole_running_mo_group(own_url)

  if not should_shutdown then
    vim.iter(bufs):each(close_by_mo)
    return
  end

  -- shutdown 前に mo のセッション状態から確実に消しておく (でないと次回
  -- 起動時にセッションが復元され、古いファイルが残ってしまう)。close と
  -- shutdown の順序が入れ替わらないよう detach せずに待つ。
  for _, buf in ipairs(bufs) do
    local cmd = mo_close_cmd(buf)
    if cmd then
      vim.system(cmd):wait(2000)
    end
  end

  vim.system({ 'mo', '--shutdown', '-p', tostring(port) }, { detach = true })
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
    close_or_shutdown_mo(vim.api.nvim_list_bufs())
  end,
})

vim.keymap.set('n', '<Leader>co', open_by_mo, { desc = 'Preview by mo', buf = 0 })
vim.keymap.set('n', '<Leader>cO', open_by_mo_and_chroma, { desc = 'Preview by mo and open in chroma', buf = 0 })
vim.keymap.set('n', '<Leader>Tm', require('render-markdown').buf_toggle, { desc = 'Toggle markup hiding', buf = 0 })
