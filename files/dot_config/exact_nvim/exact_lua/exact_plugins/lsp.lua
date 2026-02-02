return {
  {
    'mason-org/mason.nvim',
    version = 'v2.1.0',
  },

  {
    'neovim/nvim-lspconfig',
    hash = 'c4f67bf85b01a57e3c130352c0a0e453ab8cd5b9',
    event = { 'BufReadPre', 'BufNewFile' },
  },

  {
    'mason-org/mason-lspconfig.nvim',
    version = 'v2.1.0',
    dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
  },
}
