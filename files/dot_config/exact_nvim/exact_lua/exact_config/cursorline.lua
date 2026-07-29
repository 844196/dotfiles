local M = {}

---@alias CursorLineState
---| '"both"'
---| '"number"'

---@type CursorLineState
local state = 'both'
local prev_state = state

---@param new_state CursorLineState
local function set(new_state)
  vim.wo.cursorlineopt = new_state

  prev_state = state
  state = new_state
end

---@param opts { initial_state: CursorLineState }
function M.setup(opts)
  local initial_state = opts.initial_state
  prev_state = initial_state

  vim.wo.cursorline = initial_state == 'both'
  set(initial_state)
end

function M.number()
  set('number')
end

function M.both()
  set('both')
end

function M.toggle()
  set(state == 'number' and 'both' or 'number')
end

function M.rollback_state()
  set(prev_state)
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  callback = function()
    vim.wo.cursorline = true
    vim.wo.cursorlineopt = state
  end,
})
vim.api.nvim_create_autocmd('WinLeave', {
  callback = function()
    vim.wo.cursorline = false
  end,
})

return M
