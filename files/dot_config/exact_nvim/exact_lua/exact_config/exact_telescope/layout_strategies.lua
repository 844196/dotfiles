local strategies = require('telescope.pickers.layout_strategies')

-- VSCode の Peek 風レイアウト。
-- カーソル行の直下に、元ウィンドウの幅いっぱいのパネルを出す。下に入らなければ上に出す。
--
--   ┌─ 元ウィンドウ ────────────────────────────┐
--   │ local function foo()                      │
--   │   return bar█                             │  ← カーソル行
--   │ ╭───────────────────╮╭──────────────────╮ │
--   │ │                   ││ ❯ query          │ │
--   │ │      preview      │├──────────────────┤ │
--   │ │                   ││ ▌ result         │ │
--   │ ╰───────────────────╯╰──────────────────╯ │
--   └───────────────────────────────────────────┘

-- 受け付ける layout_config キー。値の文字列は strategies._format() がそのままヘルプに流し込む
local peek_config = {
  height = { 'パネル全体の高さ (枠線込み)', 'See |resolver.resolve_height()|' },
  width = { 'パネル全体の幅。省略時は元ウィンドウの幅いっぱい', 'See |resolver.resolve_width()|' },
  preview_width = { 'preview の幅。パネル幅に対する割合', 'See |resolver.resolve_width()|' },
  preview_cutoff = 'パネル幅がこの値を下回ったら preview を出さない',
  prompt_position = { 'prompt の位置', "Available Values: 'top', 'bottom'" },
  mirror = 'preview を左に置く',
  align_to_text = '行番号・サインカラムを避けてテキストの左端に揃える',
}

-- 既定値は themes.lua ではなくここに置く。
-- telescope/builtin/init.lua の apply_config は `vim.tbl_extend('force', defaults, opts)` という
-- 浅いマージなので、theme が返した layout_config は呼び出し側が layout_config を渡した時点で
-- テーブルごと消える。strategy 側の既定値はその経路を通らないので影響を受けない。
--
-- mirror / preview_width が「覗いた中身を左に大きく、候補を右に」なのも見た目ではなく
-- 配置の既定値なので、themes.lua ではなくこちらの責務にしている。
local peek_defaults = {
  height = 12,
  -- width は意図的に未設定。nil = 元ウィンドウの幅いっぱい
  preview_width = 0.62,
  preview_cutoff = 80,
  prompt_position = 'top',
  mirror = true,
  align_to_text = false,
}

--- 元ウィンドウのアンカー情報を取る
---@param winid integer
---@return integer cursor_line カーソルがあるスクリーン行 (1-based)
---@return integer win_col ウィンドウ左端のスクリーン桁 (0-based)
---@return integer win_width ウィンドウの幅
local function peek_anchor(winid)
  -- nvim_win_get_position は { row, col } でどちらも 0-based。tabline のぶんはここに
  -- 含まれるので、カーソル相対のレイアウトでは calc_tabline 相当の補正は要らない
  local pos = vim.api.nvim_win_get_position(winid)
  -- winline() はテキスト領域内の 1-based 行。winbar があるとその分だけ下にずれる
  local winbar = (vim.fn.exists('&winbar') == 1 and vim.wo[winid].winbar ~= '') and 1 or 0
  local cursor_line = pos[1] + winbar + vim.api.nvim_win_call(winid, vim.fn.winline)
  return cursor_line, pos[2], vim.api.nvim_win_get_width(winid)
end

strategies.peek = function(picker, max_columns, max_lines, override_layout)
  local resolve = require('telescope.config.resolve')

  -- make_documented_layout は telescope 内部の local なので、第4引数の解決は自前でやる。
  -- 優先順位は本体と同じ: override_layout > picker.layout_config > 既定値
  local cfg = strategies._validate_layout_config(
    'peek',
    peek_config,
    vim.tbl_deep_extend('keep', override_layout or {}, picker.layout_config or {}),
    vim.tbl_deep_extend('keep', { peek = peek_defaults }, require('telescope.config').values.layout_config)
  )

  local initial_options = require('telescope.pickers.window').get_initial_window_options(picker)
  local prompt = initial_options.prompt
  local results = initial_options.results
  local preview = initial_options.preview

  local bs = (picker.window.border == false) and 0 or 1
  local cursor_line, win_col, win_width = peek_anchor(picker.original_win_id)

  -- 横
  local left = win_col
  local avail = win_width
  if cfg.align_to_text then
    local textoff = vim.fn.getwininfo(picker.original_win_id)[1].textoff
    left, avail = left + textoff, avail - textoff
  end
  avail = math.min(avail, max_columns - left)

  local width = cfg.width and resolve.resolve_width(cfg.width)(picker, avail, max_lines) or avail
  width = math.max(math.min(width, avail), 2 * bs + 1)

  -- 縦。prompt(1) + results(1) + 枠線で、prompt と results は枠線を 1 行共有する
  local min_height = 2 + 3 * bs
  local height = math.max(resolve.resolve_height(cfg.height)(picker, max_columns, max_lines), min_height)

  local below_top = cursor_line + 1 -- カーソル直下 = パネル上端の枠線
  local room_below = max_lines - below_top + 1
  local room_above = cursor_line - 1

  local top
  if height <= room_below then
    top = below_top
  elseif height <= room_above then
    top = cursor_line - height
  elseif room_below >= room_above then
    height, top = math.max(room_below, min_height), below_top
  else
    height = math.max(room_above, min_height)
    top = cursor_line - height
  end
  -- 画面外に出てしまう場合はスライドさせて収める
  top = math.max(1, math.min(top, max_lines - height + 1))

  -- 配分
  local show_preview = picker.previewer and width >= cfg.preview_cutoff
  if show_preview then
    -- 2 カラム = 枠線 4 桁。results 側に最低 1 桁残す
    preview.width = resolve.resolve_width(cfg.preview_width)(picker, width, max_lines)
    preview.width = math.max(math.min(preview.width, width - 4 * bs - 1), 1)
    results.width = width - preview.width - 4 * bs
  else
    preview.width = 0
    results.width = width - 2 * bs
  end
  prompt.width = results.width

  prompt.height = 1
  results.height = height - prompt.height - 3 * bs
  preview.height = height - 2 * bs

  -- 座標。popup.nvim の line/col は 1-based で、枠線の内側を指す
  local inner_top = top + bs
  local inner_left = left + bs + 1

  if show_preview and cfg.mirror then
    preview.col = inner_left
    prompt.col = preview.col + preview.width + 2 * bs
  else
    prompt.col = inner_left
    preview.col = prompt.col + results.width + 2 * bs
  end
  results.col = prompt.col

  preview.line = inner_top
  if cfg.prompt_position == 'top' then
    prompt.line = inner_top
    results.line = prompt.line + prompt.height + bs
  elseif cfg.prompt_position == 'bottom' then
    results.line = inner_top
    prompt.line = results.line + results.height + bs
  else
    error(string.format('Unknown prompt_position: %s\n%s', cfg.prompt_position, vim.inspect(cfg)))
  end

  return {
    prompt = prompt,
    results = results,
    preview = show_preview and preview.width > 0 and preview,
  }
end
