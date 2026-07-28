local function oil_select_keeping_focus(select_opts)
  return function()
    local oil = require('oil')
    local winid = vim.api.nvim_get_current_win()
    oil.select(select_opts, function()
      vim.api.nvim_set_current_win(winid)
    end)
  end
end

require('oil').setup({
  view_options = {
    show_hidden = true
  },
  keymaps = {
    ['<Esc>'] = { 'actions.close', mode = 'n' },
    ['<C-g>'] = { 'actions.close', mode = 'n' },
    ['q'] = { 'actions.close', mode = 'n' },
    ['<C-h>'] = false,
    ['<C-x>'] = {
      desc = 'Open the entry in a horizontal split, keeping focus on oil',
      mode = 'n',
      callback = oil_select_keeping_focus({ horizontal = true }),
    },
    ['<C-s>'] = {
      desc = 'Open the entry in a horizontal split, keeping focus on oil',
      mode = 'n',
      callback = oil_select_keeping_focus({ horizontal = true }),
    },
    ['<C-v>'] = {
      desc = 'Open the entry in a vertical split, keeping focus on oil',
      mode = 'n',
      callback = oil_select_keeping_focus({ vertical = true }),
    },
  },
})
