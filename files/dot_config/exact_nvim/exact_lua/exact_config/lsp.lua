require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'codebook',
    'lua_ls',
    'jsonls',
    'yamlls',
    'tombi',
    'ts_ls',
  },
})
require('lazydev').setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

require('nvim-lightbulb').setup({
  autocmd = { enabled = true },
  sign = { enabled = false },
  float = { enabled = true },
})

require('tiny-code-action').setup({
  picker = {
    'buffer',
    opts = {
      keymaps = {
        close = { '<Esc>', '<C-g>', 'q' },
      },
    },
  },
})
