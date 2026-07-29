local M = {}

---@alias NumberState
---| '"absolute"'
---| '"relative"'
---| '"off"'

---@type NumberState
local state = 'off'
local prev_state = state

---@param name '"number"'|'"relativenumber"'
---@param value boolean
local function set_win_option(name, value)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_set_option_value(name, value, { win = win })
  end
end

---@param new_state NumberState
local function set(new_state)
  if new_state == 'absolute' then
    set_win_option('number', true)
    set_win_option('relativenumber', false)
  elseif new_state == 'relative' then
    set_win_option('number', true)
    set_win_option('relativenumber', true)
  else -- off
    set_win_option('number', false)
    set_win_option('relativenumber', false)
  end

  prev_state = state
  state = new_state
end

---@param opts { initial_state: NumberState }
function M.setup(opts)
  local initial_state = opts.initial_state
  prev_state = initial_state

  set(initial_state)
end

function M.absolute()
  set('absolute')
end

function M.relative()
  set('relative')
end

function M.off()
  set('off')
end

function M.toggle_absolute()
  if state == 'absolute' then
    set('off')
  elseif state == 'relative' then
    set('absolute')
  else
    set('absolute')
  end
end

function M.toggle_relative()
  if state == 'absolute' then
    set('relative')
  elseif state == 'relative' then
    set('off')
  else
    set('relative')
  end
end

function M.toggle_number()
  if state == 'absolute' then
    set('off')
  elseif state == 'relative' then
    set('off')
  else
    set('absolute')
  end
end

function M.rollback_state()
  set(prev_state)
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  callback = function()
    vim.wo.number = state ~= "off"
    vim.wo.relativenumber = state == "relative"
  end,
})

return M
