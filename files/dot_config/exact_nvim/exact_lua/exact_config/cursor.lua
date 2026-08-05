local M = {}

---@param fallback string|(fun(): string)
---@param opts { multiline?: 'KEEP' | 'REPLACE_SPACE' }?
function M.region_or(fallback, opts)
  opts = vim.tbl_deep_extend('force', { multiline = 'REPLACE_SPACE' }, opts or {})

  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' or mode == '\22' then
    local region = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = mode })
    return table.concat(region, opts.multiline == 'KEEP' and '\n' or ' ')
  else
    return type(fallback) == 'string' and fallback or fallback()
  end
end

function M.cword()
  return vim.fn.expand('<cword>')
end

function M.cfile()
  return vim.fn.expand('<cfile>')
end

return M
