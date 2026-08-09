local lint = require('lint')

lint.linters_by_ft = {
  -- 今のところない
}

table.insert(
  lint.linters.cspell.args,

  -- e.g.
  --   files/dot_config/exact_nvim/init.lua:140:34 - Unknown word (lnumfunc) Suggestions: []
  --   files/dot_config/exact_nvim/init.lua:143:31 - Unknown word (gitsigns) Suggestions: [listings, gissing, givings, gassings, gildings]
  --   files/dot_config/exact_nvim/init.lua:284:56 - Unknown word (hlsearch) Suggestions: [search, hearth]
  '--show-suggestions'
)

lint.linters.cspell = require('lint.util').wrap(
  lint.linters.cspell,

  ---@param diag vim.Diagnostic
  ---@return CSpellDiagnostic
  function(diag)
    diag.severity = vim.diagnostic.severity.HINT

    local message, suggestions_str = diag.message:match('^(.-)%s*Suggestions: %[(.-)%]$')
    if message then
      diag.message = message

      ---@type string[]
      local suggestions = {}
      for word in suggestions_str:gmatch('[^,%s]+') do
        table.insert(suggestions, word)
      end

      diag.user_data = { suggestions = suggestions }
    end

    return diag
  end
)

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = function()
    lint.try_lint()
    lint.try_lint('cspell')
  end,
})
