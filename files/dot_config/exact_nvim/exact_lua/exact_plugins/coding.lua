return {
  {
    'nvim-mini/mini.pairs',
    version = 'v0.17.0',
    config = function()
      require('mini.pairs').setup()
    end,
  },

  {
    'nvim-mini/mini.move',
    version = 'v0.17.0',
    config = function()
      require('mini.move').setup({
        -- 忘れられないの
        mappings = {
          -- Normal mode
          line_left = '<M-Left>',
          line_right = '<M-Right>',
          line_up = '<M-Up>',
          line_down = '<M-Down>',

          -- Visual mode
          left = '<M-Left>',
          right = '<M-Right>',
          up = '<M-Up>',
          down = '<M-Down>',
        },
      })
    end,
  },

  {
    'folke/which-key.nvim',
    version = 'v3.17.0',
    event = 'VeryLazy',
    opts = {
      delay = 0,
      triggers = {
        { '<Leader>', mode = { 'n', 'v' } },
        { '<LocalLeader>', mode = { 'n', 'v' } },
      },
      plugins = {
        marks = false,
        registers = false,
        spelling = { enabled = false }
      },
    },
  },
}
