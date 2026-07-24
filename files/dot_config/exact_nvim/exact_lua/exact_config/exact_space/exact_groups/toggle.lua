require('which-key').add({ { '<Leader>t', group = 'Toggle' } })

local function set_win_option(name, value)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_set_option_value(name, value, { win = win })
  end
end

vim.keymap.set('n', '<Leader>tnn', function()
  if vim.o.number then
    set_win_option('number', false)
    set_win_option('relativenumber', false)
  else
    set_win_option('number', true)
    set_win_option('relativenumber', false)
  end
end)
vim.keymap.set('n', '<Leader>tna', function()
  local number, relativenumber = vim.o.number, vim.o.relativenumber
  if number == false and relativenumber == false then
    set_win_option('number', true)
  elseif number == true and relativenumber == false then
    set_win_option('number', false)
  elseif number == true and relativenumber == true then
    set_win_option('relativenumber', false)
  else -- number == false and relativenumber == true
    set_win_option('number', false)
    set_win_option('relativenumber', false)
  end
end)
vim.keymap.set('n', '<Leader>tnr', function()
  local number, relativenumber = vim.o.number, vim.o.relativenumber
  if number == false and relativenumber == false then
    set_win_option('number', true)
    set_win_option('relativenumber', true)
  elseif number == true and relativenumber == false then
    set_win_option('relativenumber', true)
  else -- (number == true and relativenumber == true) or (number == false and relativenumber == true)
    set_win_option('number', false)
    set_win_option('relativenumber', false)
  end
end)

vim.keymap.set('n', '<Leader>thh', function()
  vim.g.cursorlineopt_state = vim.g.cursorlineopt_state == 'number' and 'both' or 'number'
  vim.wo.cursorlineopt = vim.g.cursorlineopt_state
end)

vim.keymap.set('n', '<Leader>tf', function()
  vim.o.colorcolumn = vim.o.colorcolumn ~= '120' and '120' or ''
end)

vim.keymap.set('n', '<Leader>tS', require('config.space.codebook').toggle, { desc = 'Toggle spell check' })
