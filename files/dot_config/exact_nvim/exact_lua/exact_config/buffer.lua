local M = {}

---@param predicate string | fun(buf: integer): boolean
---@param handle_create fun(buf: integer)
---@return integer
function M.find_or_create(predicate, handle_create)
  local predicate_func = type(predicate) == 'function'
      and predicate
      ---@param b integer
      ---@return boolean
      or function(b)
        return (vim.fn.bufname(b) == predicate) or (vim.api.nvim_buf_get_name(b) == predicate)
      end

  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and predicate_func(b) then
      return b
    end
  end

  local buf = vim.api.nvim_create_buf(false, false)

  if type(predicate) == 'string' then
    vim.api.nvim_buf_set_name(buf, predicate)
  end
  handle_create(buf)

  return buf
end

---@param buf integer
function M.ephemeralize(buf)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].modeline = false
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = true

  local handle_quit = function()
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  vim.api.nvim_create_autocmd('VimLeavePre', { callback = handle_quit })
  vim.api.nvim_create_autocmd('User', { pattern = 'SessionWritePre', callback = handle_quit })
end

---@param opts? { type?: ('absolute' | 'relative') }
---@return string
function M.path(opts)
  ---@type { type: ('absolute' | 'relative') }
  opts = vim.tbl_deep_extend('force', { type = 'relative' }, opts or {})

  local abs = vim.fs.normalize(vim.api.nvim_buf_get_name(0))

  return opts.type == 'absolute' and abs or vim.fn.fnamemodify(abs, ':~:.')
end

return M
