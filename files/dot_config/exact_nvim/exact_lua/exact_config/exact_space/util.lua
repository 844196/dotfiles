local M = {}

-- ビジュアルモードなら選択範囲、そうでなければ fallback() の返り値を返す
function M.selection_or(fallback)
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    return fallback()
  end
  vim.cmd.normal({ vim.keycode('<Esc>'), bang = true })
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  local lines = vim.fn.getline(s[2], e[2])
  if #lines == 0 then return '' end
  lines[#lines] = string.sub(lines[#lines], 1, e[3])
  lines[1] = string.sub(lines[1], s[3])
  return table.concat(lines, ' ')
end

return M
