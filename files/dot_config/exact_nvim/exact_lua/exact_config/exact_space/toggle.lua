vim.keymap.set('n', '<Leader>tnn', function()
  if vim.o.number then
    vim.cmd('windo set nonumber')
    vim.cmd('windo set norelativenumber')
  else
    vim.cmd('windo set number')
    vim.cmd('windo set norelativenumber')
  end
end)
vim.keymap.set('n', '<Leader>tna', function()
  local number, relativenumber = vim.o.number, vim.o.relativenumber
  if number == false and relativenumber == false then
    vim.cmd('windo set number')
  elseif number == true and relativenumber == false then
    vim.cmd('windo set nonumber')
  elseif number == true and relativenumber == true then
    vim.cmd('windo set norelativenumber')
  else -- number == false and relativenumber == true
    vim.cmd('windo set nonumber')
    vim.cmd('windo set norelativenumber')
  end
end)
vim.keymap.set('n', '<Leader>tnr', function()
  local number, relativenumber = vim.o.number, vim.o.relativenumber
  if number == false and relativenumber == false then
    vim.cmd('windo set number')
    vim.cmd('windo set relativenumber')
  elseif number == true and relativenumber == false then
    vim.cmd('windo set relativenumber')
  else -- (number == true and relativenumber == true) or (number == false and relativenumber == true)
    vim.cmd('windo set nonumber')
    vim.cmd('windo set norelativenumber')
  end
end)

vim.keymap.set('n', '<Leader>thh', function()
  vim.g.cursorlineopt_state = vim.g.cursorlineopt_state == 'number' and 'both' or 'number'
  vim.wo.cursorlineopt = vim.g.cursorlineopt_state
end)

vim.keymap.set('n', '<Leader>tf', function()
  vim.o.colorcolumn = vim.o.colorcolumn ~= '120' and '120' or ''
end)
