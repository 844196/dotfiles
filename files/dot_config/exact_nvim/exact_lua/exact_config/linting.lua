local lint = require('lint')

lint.linters_by_ft = {
  -- 今のところない
}

lint.linters.cspell = require('lint.util').wrap(lint.linters.cspell, function(diag)
  diag.severity = vim.diagnostic.severity.HINT
  return diag
end)

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = function()
    lint.try_lint()
    lint.try_lint('cspell')
  end,
})
