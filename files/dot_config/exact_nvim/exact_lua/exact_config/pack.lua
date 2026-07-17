vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind

  if name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
    vim.system({ 'make' }, { cwd = ev.data.path })
  end

  vim.system({ 'chezmoi', 'add', '~/.config/nvim/nvim-pack-lock.json' })
end })

vim.pack.add({
  {
    src = 'https://github.com/mason-org/mason.nvim',
    version = '2a6940af80375532e5e9e7c1f2fc6319a1b7a69d',
  },
  {
    src = 'https://github.com/mason-org/mason-lspconfig.nvim',
    version = 'a4068c3ebd4cb335b25239e5ea35c22ee6007962',
  },
  {
    src = 'https://github.com/neovim/nvim-lspconfig',
    version = 'd5b6e3db4c17b0146f63a2fc47e2027a754b2cb1',
  },
  {
    src = 'https://github.com/folke/lazydev.nvim',
    version = 'ff2cbcba459b637ec3fd165a2be59b7bbaeedf0d',
  },
  {
    src = 'https://github.com/b0o/SchemaStore.nvim',
    version = 'e954496f8ef22904e8a84f5078f4a110fdc7a0d3',
  },
  {
    src = 'https://github.com/nvim-mini/mini.completion',
    version = 'd2a2b2a2b5350b713ade3bb744df39eee7d4229b',
  },

  {
    src = 'https://github.com/nvim-tree/nvim-web-devicons',
    version = '8dcb311b0c92d460fac00eac706abd43d94d68af',
  },

  {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
    version = 'v0.2.0',
  },
  {
    src = 'https://github.com/nvim-lua/plenary.nvim',
    version = "74b06c6c75e4eeb3108ec01852001636d85a932b",
  },
  {
    src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
    version = 'b25b749b9db64d375d782094e2b9dce53ad53a40',
  },

  {
    src = 'https://github.com/folke/tokyonight.nvim',
    version = 'v4.14.1',
  },

  {
    src = 'https://github.com/stevearc/oil.nvim',
    version = 'v2.16.0',
  },

  {
    src = 'https://github.com/folke/which-key.nvim',
    version = 'v3.17.0',
  },

  {
    src = 'https://github.com/nvim-mini/mini.pairs',
    version = 'v0.17.0',
  },

  {
    src = 'https://github.com/nvim-mini/mini.move',
    version = 'v0.17.0',
  },

  {
    src = 'https://github.com/luukvbaal/statuscol.nvim',
    version = 'c46172d0911aa5d49ba5f39f4351d1bb7aa289cc',
  },

  {
    src = 'https://github.com/akinsho/bufferline.nvim',
    version = "v4.9.1",
  },

  {
    src = 'https://github.com/b0o/incline.nvim',
    version = '8b54c59bcb23366645ae10edca6edfb9d3a0853e',
  },

  {
    src = 'https://github.com/folke/snacks.nvim',
    version = 'v2.30.0',
  },
})

require('telescope').load_extension('fzf')
