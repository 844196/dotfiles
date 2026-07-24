local positions = { 'zz', 'zt', 'zb' }
local state = { win = nil, lnum = nil, topline = nil, idx = 0 }

return function()
  local win = vim.api.nvim_get_current_win()
  local lnum = vim.api.nvim_win_get_cursor(win)[1]

  local repeated = state.win == win
    and state.lnum == lnum
    and state.topline == vim.fn.winsaveview().topline

  state.idx = repeated and (state.idx % #positions) + 1 or 1
  vim.cmd.normal({ positions[state.idx], bang = true })

  state.win, state.lnum = win, lnum
  state.topline = vim.fn.winsaveview().topline
end
