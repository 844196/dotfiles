require('tokyonight').setup({
  style = 'night',
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
    floats = 'transparent',
  },
  on_colors = function(colors)
    -- 行番号の明るさを下げる
    colors.fg_gutter = require('tokyonight.util').blend_bg(colors.fg_gutter, 0.7)
  end,
  on_highlights = function(hl, colors)
    local util = require('tokyonight.util')
    hl.WinSeparator = {
      fg = '#0e0e14',
      bold = true,
    }
    hl.DiagnosticVirtualTextHint = {
      fg = util.blend_bg(colors.hint, 0.5),
      bg = colors.none,
    }
    hl.DiagnosticVirtualTextInfo = {
      fg = util.blend_bg(colors.info, 0.5),
      bg = colors.none,
    }
    hl.DiagnosticVirtualTextWarn = {
      fg = util.blend_bg(colors.warning, 0.5),
      bg = colors.none,
    }
    hl.DiagnosticVirtualTextError = {
      fg = util.blend_bg(colors.error, 0.75),
      bg = colors.none,
    }
    hl.FloatTitle = {
      fg = colors.comment,
      bold = true,
    }
    hl.FloatBorder = {
      fg = util.darken(colors.comment, 0.5),
      bold = true,
    }

    hl.TelescopePromptTitle = hl.FloatTitle
    hl.TelescopePromptBorder = hl.FloatBorder
    hl.TelescopeResultsTitle = hl.FloatTitle
    hl.TelescopeResultsBorder = hl.FloatBorder
    hl.TelescopePreviewTitle = hl.FloatTitle
    hl.TelescopePreviewBorder = hl.FloatBorder
    hl.TelescopePromptPrefix = {
      fg = colors.blue,
    }
    hl.TelescopeMultiIcon = {
      fg = colors.fg,
    }
    hl.TelescopeMultiSelection = {
      fg = colors.fg,
    }
    hl.TelescopeResultsNormal = {
      fg = colors.dark3,
    }
    hl.TelescopeSelection = {
      bg = util.blend_bg(colors.bg_highlight, 0.5),
    }
    hl.TelescopeMatching = {
      fg = colors.blue,
    }

    hl.SnacksIndent = {
      fg = util.blend_bg(colors.fg_gutter, 0.2),
    }
    hl.SnacksIndentScope = {
      fg = colors.fg_gutter,
    }
    hl.GitSignsAdd = {
      fg = util.blend_bg(colors.green, 0.8),
    }
    hl.GitSignsAddLn = {
      bg = util.blend_bg(colors.green, 0.1),
    }
    hl.GitSignsChange = {
      fg = util.blend_bg(colors.blue, 0.9),
    }
    hl.GitSignsChangeLn = {
      bg = util.blend_bg(colors.blue, 0.1),
    }
    hl.GitSignsDelete = {
      fg = util.blend_bg(colors.red, 0.7),
    }
    hl.GitSignsDeleteLn = {
      bg = util.blend_bg(colors.red, 0.1),
    }
    hl.GitSignsTopDelete = {
      fg = util.blend_bg(colors.red, 0.7),
    }
    hl.GitSignsDeleteVirt = {
      fg = util.blend_bg(colors.red, 0.7),
    }
    hl.GitSignsDeleteVirtLn = {
      bg = util.blend_bg(colors.red, 0.1),
      fg = util.blend_bg(colors.red, 0.7, util.blend_bg(colors.red, 0.1)),
    }
    hl.CodeDiffFiller = {
      fg = colors.fg_gutter,
    }
  end,
})

vim.cmd([[colorscheme tokyonight]])
