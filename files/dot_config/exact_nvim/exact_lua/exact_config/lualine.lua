local night = require('tokyonight.colors').setup({ style = 'night' })
local util = require('tokyonight.util')

local bg_base = night.bg_statusline
local fg_base = util.blend_bg(night.fg_dark, 0.6, bg_base)

local bg_sub = util.darken(night.dark3, 0.1, night.bg)
local fg_sub = util.blend_bg(night.fg_dark, 0.6, bg_sub)

local bg_base_inactive = bg_base
local fg_base_inactive = util.blend_bg(night.fg_dark, 0.3, bg_base_inactive)
local bg_sub_inactive = bg_sub
local fg_sub_inactive = util.blend_bg(night.fg_dark, 0.3, bg_sub_inactive)

-- ビルトインのパディングしてて気持ち悪い
local function location()
  local line = vim.fn.line('.')
  local col = vim.fn.charcol('.')
  return string.format('%d:%2d', line, col)
end

local function filestatus()
  if (not vim.bo.modifiable) or vim.bo.readonly then
    return '%%'
  end
  if vim.bo.modified then
    return '*'
  end
  return '-'
end

require('lualine').setup({
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    theme = {
      normal = {
        a = { bg = night.blue, fg = night.bg_dark, gui = 'bold' },
        b = { bg = bg_sub, fg = fg_sub },
        c = { bg = bg_base, fg = fg_base },
        x = { bg = bg_base, fg = fg_base },
        y = { bg = bg_sub, fg = fg_sub },
        z = { bg = bg_base, fg = fg_base },
      },
      insert = {
        a = { bg = night.green, fg = night.bg_dark, gui = 'bold' },
        z = { bg = bg_base, fg = fg_base },
      },
      visual = {
        a = { bg = night.yellow, fg = night.bg_dark, gui = 'bold' },
        z = { bg = bg_base, fg = fg_base },
      },
      replace = {
        a = { bg = night.red, fg = night.bg_dark, gui = 'bold' },
        z = { bg = bg_base, fg = fg_base },
      },
      command = {
        a = { bg = fg_base, fg = bg_base, gui = 'bold' },
        z = { bg = bg_base, fg = fg_base },
      },
      inactive = {
        a = { bg = bg_base_inactive, fg = fg_base, gui = 'bold' },
        b = { bg = bg_sub_inactive, fg = fg_sub },
        c = { bg = bg_base_inactive, fg = fg_base_inactive },
        x = { bg = bg_base_inactive, fg = fg_base_inactive },
        y = { bg = bg_sub_inactive, fg = fg_sub_inactive },
        z = { bg = bg_base_inactive, fg = fg_base_inactive },
      },
    },
    refresh = {
      events = {
        'WinEnter',
        'BufEnter',
        'BufWritePost',
        'SessionLoadPost',
        'FileChangedShellPost',
        'VimResized',
        'Filetype',
        'CursorMoved',
        'CursorMovedI',
        'ModeChanged',
        'RecordingEnter',
        'RecordingLeave',
      },
    }
  },
  sections = {
    lualine_a = {
      {
        function()
          return tostring(vim.api.nvim_win_get_number(0))
        end,
        separator = { right = '' },
      },
    },
    lualine_b = {
      {
        filestatus,
        fmt = function(symbol)
          return ' ' .. symbol
        end,
        color = { fg = night.fg_sidebar, gui = 'bold' },
        padding = 0,
      },
      {
        '%t',
        type = 'stl',
        color = { fg = night.fg_sidebar, gui = 'bold' },
      },
      {
        'filetype',
        icons_enabled = false,
        color = { bg = bg_base, fg = fg_base },
        separator = { left = '', right = '' },
        padding = 2,
      },
      {
        function()
          return 'recording @' .. vim.fn.reg_recording()
        end,
        cond = function()
          return vim.fn.reg_recording() ~= ''
        end,
        color = { bg = bg_sub, fg = night.red1 },
      },
      {
        'searchcount',
        color = { bg = bg_sub, fg = fg_sub },
      },
    },
    lualine_c = {
      {
        ' ',
        type = 'stl',
        separator = { left = '' },
        padding = 0,
      },
      {
        '',
        type = 'stl',
      },
    },
    lualine_x = {
      {
        'lsp_status',
        icon = '',
        symbols = {
          done = '',
        },
        show_name = false,
      },
      {
        'diagnostics',
        colored = false,
      },
      {
        ' ',
        type = 'stl',
        padding = 0,
        separator = { left = '', right = '' },
        color = { bg = bg_base },
      },
    },
    lualine_y = {
      {
        'encoding',
        show_bomb = true,
      },
      {
        'fileformat',
        symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
      },
      {
        location
      }
    },
    lualine_z = {
      {
        '%P',
        type = 'stl',
        separator = { left = '' },
        padding = 2,
      },
    },
  },
  inactive_sections = {
    lualine_a = {
      {
        function()
          return tostring(vim.api.nvim_win_get_number(0))
        end,
        separator = { right = '' },
      },
    },
    lualine_b = {
      {
        filestatus,
        fmt = function(symbol)
          return ' ' .. symbol
        end,
        padding = 0,
      },
      {
        '%t',
        type = 'stl',
      },
      {
        'filetype',
        icons_enabled = false,
        color = { bg = bg_base_inactive, fg = fg_base_inactive },
        separator = { left = '', right = '' },
        padding = 2,
      },
    },
    lualine_c = {
      {
        ' ',
        type = 'stl',
        separator = { left = '' },
        padding = 0,
      },
      {
        '',
        type = 'stl',
      },
    },
    lualine_x = {
      {
        ' ',
        type = 'stl',
        padding = 0,
        separator = { left = '', right = '' },
        color = { bg = bg_base_inactive },
      },
    },
    lualine_y = {
      {
        'encoding',
        show_bomb = true,
      },
      {
        'fileformat',
        symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
      },
      {
        location
      }
    },
    lualine_z = {
      {
        '%P',
        type = 'stl',
        separator = { left = '' },
        padding = 2,
      },
    },
  },
})
