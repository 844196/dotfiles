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

local function indentinfo()
  local shiftwidth = vim.bo.shiftwidth
  if shiftwidth == 0 then
    shiftwidth = vim.bo.tabstop
  end
  if vim.bo.expandtab then
    return 'Spc:' .. shiftwidth
  end
  return 'Tab:' .. shiftwidth
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

-- nvim 起動時の cwd。以後 :cd 等で変わっても基準は変えない。
local start_cwd = vim.uv.cwd()

---@param path string 絶対パス (末尾のセパレータはあってもなくてもよい)
---@param base string|nil 基準ディレクトリ
---@return string|nil base 配下なら base からの相対パス (base 自身なら '')。配下でなければ nil
local function relative_to(path, base)
  if not base then
    return nil
  end
  if path == base then
    return ''
  end
  local prefix = base .. '/'
  if path:sub(1, #prefix) == prefix then
    return path:sub(#prefix + 1)
  end
  return nil
end

---@param path string 絶対ディレクトリパス
---@return string 起動時 cwd 相対 > ~/ 相対 > 絶対パス の優先順で短縮したパス
local function shorten_dir(path)
  -- ルート ('/') はこのパターンにマッチしないので空文字にならない
  path = path:gsub('(.)/+$', '%1')

  local rel = relative_to(path, start_cwd)
  if rel then
    return rel == '' and '.' or rel
  end

  rel = relative_to(path, vim.uv.os_homedir())
  if rel then
    return '~/' .. rel
  end

  return path
end

-- oil.nvim のバッファなら表示中のディレクトリで名前を上書きする。それ以外はそのまま (組み込みの tail 名) を返す
local function fmt_filename(name)
  local ok, oil = pcall(require, 'oil')
  local oil_dir = ok and oil.get_current_dir(0)
  if not oil_dir then
    return name
  end
  return shorten_dir(oil_dir)
end

-- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#cursor-position-ruler-and-scrollbar
-- https://github.com/NeogitOrg/neogit/discussions/1217
-- https://github.com/CKolkey/config/blob/2d9bdfbf74843d7a38b0de41a5203ee08da0500f/nvim/lua/ckolkey/plugins/ui/statusline.lua#L123-L133
local scrollbar_chars = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
local function scrollbar()
  local curr_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_line_count(0)
  local i = math.floor((curr_line - 1) / lines * #scrollbar_chars) + 1
  return string.rep(scrollbar_chars[i], 2)
end

require('lualine').setup({
  options = {
    disabled_filetypes = {
      statusline = { 'no-neck-pain' }
    },
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    theme = {
      normal = {
        a = { bg = night.blue, fg = night.bg_dark, gui = 'bold' },
        b = { bg = bg_sub, fg = fg_sub },
        c = { bg = bg_base, fg = fg_base },
        x = { bg = bg_sub, fg = fg_sub },
        y = { bg = bg_base, fg = fg_base },
        z = { bg = bg_base, fg = util.blend_bg(night.blue, 0.9, bg_base) },
      },
      insert = {
        a = { bg = night.green, fg = night.bg_dark, gui = 'bold' },
        z = { bg = bg_base, fg = util.blend_bg(night.green, 0.9, bg_base) },
      },
      visual = {
        a = { bg = night.yellow, fg = night.bg_dark, gui = 'bold' },
        z = { bg = bg_base, fg = util.blend_bg(night.yellow, 0.9, bg_base) },
      },
      replace = {
        a = { bg = night.red, fg = night.bg_dark, gui = 'bold' },
        z = { bg = bg_base, fg = util.blend_bg(night.red, 0.9, bg_base) },
      },
      command = {
        a = { bg = fg_base, fg = bg_base, gui = 'bold' },
        z = { bg = bg_base, fg = util.blend_bg(fg_base, 0.9, bg_base) },
      },
      inactive = {
        a = { bg = bg_base_inactive, fg = fg_base, gui = 'bold' },
        b = { bg = bg_sub_inactive, fg = fg_sub },
        c = { bg = bg_base_inactive, fg = fg_base_inactive },
        x = { bg = bg_sub, fg = fg_sub_inactive },
        y = { bg = bg_base, fg = fg_base_inactive },
        z = { bg = bg_base, fg = fg_base_inactive },
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
        'filename',
        file_status = false,
        fmt = fmt_filename,
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
    },
    lualine_x = {
      {
        ' ',
        type = 'stl',
        color = { bg = bg_base, fg = fg_base },
        separator = { right = '' },
        padding = 0,
      },
      {
        'diagnostics',
        colored = false,
      },
    },
    lualine_y = {
      {
        ' ',
        type = 'stl',
        separator = { left = '' },
        padding = 0,
      },
      {
        indentinfo,
      },
      {
        'encoding',
        show_bomb = true,
      },
      {
        'fileformat',
        symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
      },
      {
        location,
      },
      {
        ' ',
        type = 'stl',
        separator = { right = '' },
        padding = 0,
      },
      {
        '%P',
        type = 'stl',
        color = { bg = bg_sub, fg = fg_sub },
      },
    },
    lualine_z = {
      {
        scrollbar,
        padding = 0,
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
        'filename',
        file_status = false,
        fmt = fmt_filename,
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
    },
    lualine_x = {
      {
        ' ',
        type = 'stl',
        color = { bg = bg_base, fg = fg_base },
        separator = { right = '' },
        padding = 0,
      },
      {
        'diagnostics',
        colored = false,
      },
    },
    lualine_y = {
      {
        ' ',
        type = 'stl',
        separator = { left = '' },
        padding = 0,
      },
      {
        indentinfo,
      },
      {
        'encoding',
        show_bomb = true,
      },
      {
        'fileformat',
        symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
      },
      {
        location,
      },
      {
        ' ',
        type = 'stl',
        separator = { right = '' },
        padding = 0,
      },
      {
        '%P',
        type = 'stl',
        color = { bg = bg_sub_inactive, fg = fg_sub_inactive },
      },
    },
    lualine_z = {
      {
        '  ',
        type = 'stl',
        padding = 0,
      },
    },
  },
})
