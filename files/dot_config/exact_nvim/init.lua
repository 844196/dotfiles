local opt = vim.opt
local vscode = require('vscode')

function keymap(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true })
end

opt.ignorecase = true
opt.smartcase = true
opt.clipboard = 'unnamedplus'

keymap('n', '<CR>', 'o<ESC>')

keymap('i', '<Left>', '<C-g>U<Left>')
keymap('i', '<Right>', '<C-g>U<Right>')
keymap('i', '<Up>', '<C-g>U<Up>')
keymap('i', '<Down>', '<C-g>U<Down>')
keymap('i', '<C-a>', '<C-o>^')
keymap('i', '<C-e>', '<C-o>$')

keymap('v', 'v', 'g_')

keymap({ 'n', 'v' }, 'x', '"_x')
keymap({ 'n', 'v' }, 'c', '"_c')
keymap({ 'n', 'v' }, 's', '"_s')
keymap('v', 'p', 'pgvy')

keymap('n', '<ESC>', function()
  vim.cmd('nohlsearch')
end)

-- https://github.com/vscode-neovim/vscode-neovim/issues/1909#issuecomment-2362783237
keymap('n', 'n', function()
  -- 結果がないときにVSCode側で毎回エラーパネルが表示されて鬱陶しい
  pcall(function()
    vim.cmd('norm! n')
    vscode.call('revealLine', { args = { lineNumber = vim.fn.line('.'), at = 'center' } })
  end)
end)
keymap('n', 'N', function()
  pcall(function()
    vim.cmd('norm! N')
    vscode.call('revealLine', { args = { lineNumber = vim.fn.line('.'), at = 'center' } })
  end)
end)

keymap('n', '*', '"zyiw:let @/ = @z<CR>:<C-u>set hlsearch<CR>')
keymap('v', '*', '"zy:let @/ = @z<CR>:<C-u>set hlsearch<CR>')

keymap('n', '<C-g>', ':<C-u>set number!<CR>')

keymap({ 'n', 'v' }, '<C-j>', function()
  vscode.call('extension.changeCase')
end)

keymap({ 'n', 'v' }, '<Space>', function()
  vscode.call('vspacecode.space')
end)

keymap('n', 'g.', function()
  vscode.call('editor.action.quickFix')
end)

keymap('n', 'gr', function()
  vscode.call('editor.action.referenceSearch.trigger')
end)
