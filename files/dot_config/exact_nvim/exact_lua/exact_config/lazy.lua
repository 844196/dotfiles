vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/lazy.nvim')

require('lazy').setup({
  spec = {
    -- lazy.nvim 自身のバージョンは chezmoiexternal で管理する
    -- https://github.com/folke/lazy.nvim/issues/287#issuecomment-1369564201
    { 'folke/lazy.nvim', enabled = false },

    { import = 'plugins' },
  },
})
