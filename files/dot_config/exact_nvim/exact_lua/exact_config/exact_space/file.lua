vim.keymap.set('n', '<Leader>fj', '<Cmd>Oil<CR>', { desc = 'Jump to the current buffer file in oil' })
vim.keymap.set('n', '<Leader>fr', '<Cmd>Telescope oldfiles<CR>', { desc = 'Open a recent file' })
vim.keymap.set('n', '<Leader>fs', '<Cmd>w<CR>', { desc = 'Save a file' })
vim.keymap.set('n', '<Leader>fS', '<Cmd>wa<CR>', { desc = 'Save all files' })

vim.keymap.set('n', '<Leader>fyn', '<Cmd>let @+ = expand("%:t")<CR>', { desc = 'Copy current file name with extension' })
vim.keymap.set('n', '<Leader>fyy', '<Cmd>let @+ = expand("%:p")<CR>', { desc = 'Copy current file absolute path' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyl', function()
  local from, to = vim.fn.line('v'), vim.fn.line('.')
  if vim.fn.mode() == 'V' and from ~= to then
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. math.min(from, to) .. '-' .. math.max(from, to))
  else
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. to)
  end
end, { desc = 'Copy current file absolute path with line number(s)' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyc', '<Cmd>let @+ = expand("%:p").":".line(".").":".col(".")<CR>', { desc = 'Copy current file absolute path with line and column number' })
vim.keymap.set('n', '<Leader>fyd', '<Cmd>let @+ = expand("%:p:h")<CR>', { desc = 'Copy current directory absolute path' })
vim.keymap.set('n', '<Leader>fyY', '<Cmd>let @+ = expand("%:.")<CR>', { desc = 'Copy current file path relative to the project root' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyL', function()
  local from, to = vim.fn.line('v'), vim.fn.line('.')
  if vim.fn.mode() == 'V' and from ~= to then
    vim.fn.setreg('+', vim.fn.expand('%:.') .. ':' .. math.min(from, to) .. '-' .. math.max(from, to))
  else
    vim.fn.setreg('+', vim.fn.expand('%:.') .. ':' .. to)
  end
end, { desc = 'Copy current file path relative to the project root with line number(s)' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyC', '<Cmd>let @+ = expand("%:.").":".line(".").":".col(".")<CR>', { desc = 'Copy current file path relative to the project root with line and column number' })
vim.keymap.set('n', '<Leader>fyD', '<Cmd>let @+ = expand("%:.:h")<CR>', { desc = 'Copy current directory path relative to the project root' })

vim.keymap.set('n', '<Leader>fed', function()
  local result = vim.system({ 'chezmoi', 'source-path', vim.env.MYVIMRC }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify('chezmoi source-path failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape((result.stdout:gsub('%s+$', ''))))
end, { desc = 'Open the init.lua' })
vim.keymap.set('n', '<Leader>feD', function()
  local result = vim.system({ 'chezmoi', 'source-path', vim.env.MYVIMRC }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify('chezmoi source-path failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end
  local source_path = result.stdout:gsub('%s+$', '')
  vim.cmd.Oil(vim.fn.fnameescape(vim.fs.dirname(source_path)))
end, { desc = 'Open the nvim dotfiles in oil' })
vim.keymap.set('n', '<Leader>feR', function()
  vim.cmd.tabnew()
  vim.fn.jobstart({ 'chezmoi', 'apply', vim.fs.dirname(vim.env.MYVIMRC) }, {
    term = true,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          vim.cmd.restart()
        end)
      end
    end,
  })
  vim.cmd.startinsert()
end, { desc = 'Resync the dotfiles with nvim' })
