local M = {}

function M.get_ivy_hermit(opts)
  opts = opts or {}

  local theme_opts = {
    theme = 'bottom_pane',
    layout_strategy = 'bottom_pane',
    results_title = false,
    preview_title = false,
    borderchars = {
      prompt = { '─', '', '', '', '─', '─', '', '' },
      results = { '', '', '', '', '', '', '', '' },
      preview = { '', '', '', '│', '│', '', '', '│' },
    },
  }

  if opts.layout_config and opts.layout_config.prompt_position == 'bottom' then
    theme_opts.borderchars = {
      prompt = { '─', '', '─', '', '', '', '─', '─' },
      results = { '─', '', '', '', '─', '─', '', '' },
      preview = { '─', '', '', '│', '─', '─', '', '│' },
    }
    theme_opts.sorting_strategy = 'descending'
  end

  return vim.tbl_deep_extend('force', theme_opts, opts)
end

function M.get_peek(opts)
  opts = opts or {}

  local theme_opts = {
    theme = 'peek',
    layout_strategy = 'peek',
    results_title = false,
    -- prompt の下辺を空白にして results の上辺 (├─┤) と繋ぐ。
    -- preview は独立した箱にする。preview_cutoff / previewer = false / <Tab> の
    -- toggle_preview で実行中に出入りするため、分割線を T 字で繋ぐ構成にすると
    -- 出入りのたびに角の文字を差し替える必要が出てしまう
    borderchars = {
      prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
      preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    },
    -- layout_config は敢えて持たない。配置の既定値はすべて layout_strategies.lua 側にある
  }

  if opts.layout_config and opts.layout_config.prompt_position == 'bottom' then
    theme_opts.borderchars = {
      prompt = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      results = { '─', '│', '─', '│', '╭', '╮', '┤', '├' },
      preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    }
  end

  return vim.tbl_deep_extend('force', theme_opts, opts)
end

return M
