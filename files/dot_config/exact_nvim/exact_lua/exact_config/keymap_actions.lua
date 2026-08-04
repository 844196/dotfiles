local M = {}

local recenter_state = { win = nil, lnum = nil, topline = nil, idx = 0 }
function M.recenter()
  local positions = { 'zz', 'zt', 'zb' }
  local win = vim.api.nvim_get_current_win()
  local lnum = vim.api.nvim_win_get_cursor(win)[1]
  local topline_before = vim.fn.winsaveview().topline

  local repeated = recenter_state.win == win
    and recenter_state.lnum == lnum
    and recenter_state.topline == topline_before

  recenter_state.idx = repeated and (recenter_state.idx % #positions) + 1 or 1
  vim.cmd.normal({ positions[recenter_state.idx], bang = true })

  -- 初回 (zz) が画面を動かさなかった場合は、zz を素通りして zt から始める
  if not repeated and vim.fn.winsaveview().topline == topline_before then
    recenter_state.idx = (recenter_state.idx % #positions) + 1
    vim.cmd.normal({ positions[recenter_state.idx], bang = true })
  end

  recenter_state.win, recenter_state.lnum = win, lnum
  recenter_state.topline = vim.fn.winsaveview().topline
end

local recenter_cursor_state = { win = nil, lnum = nil, topline = nil, idx = 0 }
function M.recenter_cursor()
  local positions = { 'M', 'H', 'L' }
  local win = vim.api.nvim_get_current_win()
  local lnum_before = vim.api.nvim_win_get_cursor(win)[1]

  local repeated = recenter_cursor_state.win == win
    and recenter_cursor_state.lnum == lnum_before
    and recenter_cursor_state.topline == vim.fn.winsaveview().topline

  recenter_cursor_state.idx = repeated and (recenter_cursor_state.idx % #positions) + 1 or 1
  vim.cmd.normal({ positions[recenter_cursor_state.idx], bang = true })

  -- 初回 (M) がカーソル位置を動かさなかった場合は、M を素通りして H から始める
  if not repeated and vim.api.nvim_win_get_cursor(win)[1] == lnum_before then
    recenter_cursor_state.idx = (recenter_cursor_state.idx % #positions) + 1
    vim.cmd.normal({ positions[recenter_cursor_state.idx], bang = true })
  end

  recenter_cursor_state.win = win
  recenter_cursor_state.lnum = vim.api.nvim_win_get_cursor(win)[1]
  recenter_cursor_state.topline = vim.fn.winsaveview().topline
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

function M.open()
  local cursor = require('config.cursor')
  local path = cursor.region_or(function()
    ---@type vim.context.mods
    local ctx = {
      go = {
        isfname = vim.o.isfname .. ',@-@', -- @ を含む URL に対応する
      },
    }
    return vim._with(ctx, cursor.cfile)
  end)

  local opts = {} ---@type vim.ui.open.Opts
  if path:match('^https?://') then
    opts.cmd = { 'chroma' }
  elseif path:match('%.html?$') then
    path = 'file://' .. vim.fs.normalize(vim.fs.joinpath(vim.fn.expand('%:p:h'), path))
    opts.cmd = { 'chroma' }
  elseif vim.uv.cwd() ~= vim.fn.expand('%:h') then
    path = vim.fs.normalize(vim.fs.joinpath(vim.fn.expand('%:p:h'), path))
  end

  local _, err = vim.ui.open(path, opts)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

return M
