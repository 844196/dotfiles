local M = {}

local recenter_state = { win = nil, lnum = nil, topline = nil, idx = 0 }
function M.recenter()
  local positions = { 'zz', 'zt', 'zb' }
  local win = vim.api.nvim_get_current_win()
  local lnum = vim.api.nvim_win_get_cursor(win)[1]

  local repeated = recenter_state.win == win
    and recenter_state.lnum == lnum
    and recenter_state.topline == vim.fn.winsaveview().topline

  recenter_state.idx = repeated and (recenter_state.idx % #positions) + 1 or 1
  vim.cmd.normal({ positions[recenter_state.idx], bang = true })

  recenter_state.win, recenter_state.lnum = win, lnum
  recenter_state.topline = vim.fn.winsaveview().topline
end

local function call_or_return(given)
  if type(given) == "function" then
    return given()
  else
    return given
  end
end

function M.pmenu_visible(on_visible, otherwise)
  return function()
    if vim.fn.pumvisible() == 1 then
      return call_or_return(on_visible)
    else
      return call_or_return(otherwise)
    end
  end
end

function M.pmenu_selected(on_selected, otherwise)
  return function()
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return call_or_return(on_selected)
    else
      return call_or_return(otherwise)
    end
  end
end

-- https://neovim.io/doc/user/insert/#i_CTRL-G_U
-- https://golang.hateblo.jp/entry/2023/04/20/201352
function M.undoable_home()
  local col = vim.fn.col('.')
  local indent = vim.fn.indent('.')
  if col == indent + 1 then
    return string.rep('<C-g>U<Left>', col - 1)
  elseif col <= indent then
    return string.rep('<C-g>U<Right>', indent + 1 - col)
  else
    return string.rep('<C-g>U<Left>', col - 1 - indent)
  end
end

function M.undoable_end()
  return string.rep('<C-g>U<Right>', vim.fn.col('$') - vim.fn.col('.'))
end

return M
