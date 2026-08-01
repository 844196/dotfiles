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
    local decreased_hint = util.blend_bg(colors.hint, 0.4)
    hl.DiagnosticVirtualTextHint = {
      fg = decreased_hint,
      bg = util.blend_bg(decreased_hint, 0.1),
    }
    hl.FloatTitle = {
      fg = colors.comment,
      bold = true,
    }
    hl.FloatBorder = {
      fg = util.darken(colors.comment, 0.5),
      bold = true,
    }
    -- `Telescope<X>_<layout_strategy>` はそのレイアウト戦略でのみ `Telescope<X>` に適用される
    -- (差し替えは config.telescope が行う)。以下は画面下部に横長で表示する ivy_hermit 向けの配色。
    hl.TelescopeNormal_ivy_hermit = {
      bg = colors.bg_statusline,
    }
    hl.TelescopeResultsNormal_ivy_hermit = {
      fg = colors.dark5,
      bg = colors.bg_statusline,
    }
    hl.TelescopeSelection_ivy_hermit = {
      bg = util.blend_bg(colors.bg_highlight, 0.5, colors.bg_statusline),
    }
    hl.TelescopeMatching_ivy_hermit = {
      fg = colors.blue,
      bg = colors.bg_statusline,
    }
    hl.TelescopePromptPrefix_ivy_hermit = {
      fg = colors.blue,
    }
    hl.TelescopeMultiIcon_ivy_hermit = {
      fg = colors.fg,
    }
    hl.TelescopeMultiSelection_ivy_hermit = {
      fg = colors.fg,
    }
    hl.TelescopeResultsBorder_ivy_hermit = {
      bg = colors.bg_statusline,
    }
    hl.TelescopePreviewBorder_ivy_hermit = {
      fg = util.blend_bg(colors.bg_highlight, 0.75, colors.bg_statusline),
      bg = colors.bg_statusline,
      bold = true,
    }
    hl.TelescopePromptBorder_ivy_hermit = {
      bg = colors.bg_statusline,
    }
    hl.TelescopePromptTitle_ivy_hermit = {
      fg = colors.purple,
      bg = colors.bg_statusline,
      bold = true,
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
