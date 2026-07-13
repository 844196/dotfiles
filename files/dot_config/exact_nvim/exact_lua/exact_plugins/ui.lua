return {
  {
    'nvim-tree/nvim-web-devicons',
    hash = '8dcb311b0c92d460fac00eac706abd43d94d68af',
  },

  {
    'folke/tokyonight.nvim',
    version = 'v4.14.1',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
        },
        on_colors = function(colors)
          local util = require('tokyonight.util')

          -- 行番号の明るさを下げる
          colors.fg_gutter = util.blend_bg(colors.fg_gutter, 0.7)
        end,
        on_highlights = function(hl, colors)
          local util = require('tokyonight.util')

          hl.SnacksIndent = {
            fg = util.blend_bg(colors.fg_gutter, 0.2),
          }
          hl.SnacksIndentScope = {
            fg = colors.fg_gutter,
          }
        end,
      })

      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  {
    'luukvbaal/statuscol.nvim',
    hash = 'c46172d0911aa5d49ba5f39f4351d1bb7aa289cc',
    config = function()
      local builtin = require('statuscol.builtin')
      require('statuscol').setup({
        segments = {
          {
            text = { ' ' },
          },
          {
            condition = { builtin.not_empty, true },
            text = { builtin.lnumfunc, ' ' },
          },
          {
            text = { ' ' },
          },
        },
      })
    end,
  },

  {
    'akinsho/bufferline.nvim',
    version = "v4.9.1",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local bufferline = require('bufferline')

      bufferline.setup({
        options = {
          mode = 'tabs',
          separator_style = 'slant',
        },
      })
    end,
  },

  {
    'b0o/incline.nvim',
    hash = '8b54c59bcb23366645ae10edca6edfb9d3a0853e',
    config = function()
      require('incline').setup()

      vim.opt.laststatus = 0
      vim.opt.cmdheight = 0
    end,
  },

  {
    'folke/snacks.nvim',
    version = 'v2.30.0',
    opts = {
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    version = 'v0.2.0',
    dependencies = {
      { 'nvim-lua/plenary.nvim', hash = "b9fd5226c2f76c951fc8ed5923d85e4de065e509" },
      { 'nvim-telescope/telescope-fzf-native.nvim', hash = 'b25b749b9db64d375d782094e2b9dce53ad53a40', build = 'make' }
    },
    config = function()
      require('telescope').setup({
        defaults = {
          file_ignore_patterns = {
            "%.git/",
          },
          layout_strategy = 'horizontal',
          layout_config = {
            prompt_position = 'top',
          },
          sorting_strategy = "ascending",
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = true,
          }
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })

      require('telescope').load_extension('fzf')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<C-p>', builtin.find_files, { noremap = true, silent = true })
    end,
  },

  {
    'stevearc/oil.nvim',
    version = 'v2.16.0',
    config = function()
      require('oil').setup({
        view_options = {
          show_hidden = true
        },
        keymaps = {
          ['q'] = { 'actions.close', mode = 'n' }
        }
      })

      vim.keymap.set("n", "-", "<CMD>Oil<CR>")
      vim.keymap.set("n", "_", "<CMD>Oil .<CR>")
    end,
  },
}
