local Herdr = require('config.herdr')
local finders = require('telescope.finders')
local entry_display = require('telescope.pickers.entry_display')
local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local config = require('telescope.config').values

local displayer = entry_display.create({
  separator = ' ',
  items = {
    { width = 10 },
    { width = 1 },
    { width = 16 },
    { remaining = true },
  },
})

local function make_status_column(status)
  if status == 'idle' then
    return { '○', '@character' }
  elseif status == 'working' then
    return { '●', '@comment.warning' }
  elseif status == 'blocked' then
    return { '◉', '@comment.error' }
  elseif status == 'done' then
    return { '●', '@constant.macro' }
  elseif status == 'unknown' then
    return { '?', '@comment' }
  end
end

local function make_display(entry)
  return displayer({
    { entry.value.pane_id, 'TelescopeResultsIdentifier' },
    make_status_column(entry.value.agent_status),
    { vim.fs.basename(entry.value.cwd), 'TelescopeNormal' },
    { entry.value.name or 'claude', 'TelescopeNormal' },
  })
end

local MODEL_NAMES = { 'Opus', 'Sonnet', 'Haiku' }

local function is_separator_line(line)
  return line ~= '' and line:gsub('─', '') == ''
end

local function has_model_name(line)
  for _, name in ipairs(MODEL_NAMES) do
    if line:find(name, 1, true) then
      return true
    end
  end
  return false
end

-- Claude Codeの入力欄・ステータスバー・ショートカットヒントは末尾に固定表示され、
-- 罫線 → 入力欄 → 罫線 → ステータス行(モデル名を含む) → ヒント行の形をしている。
-- 直近のやり取りを見せたいので、このUI部分だけを除いて末尾を詰める。
-- モデル名を含む行が見当たらない場合(選択メニューなど)は何もしない。
local function strip_prompt_chrome(text)
  local lines = vim.split(text, '\n')

  local status_idx = nil
  for i = #lines, math.max(1, #lines - 10), -1 do
    if has_model_name(lines[i]) then
      status_idx = i
      break
    end
  end
  if not status_idx then
    return text
  end

  local top_sep_idx = status_idx - 1
  if top_sep_idx < 1 or not is_separator_line(lines[top_sep_idx]) then
    return text
  end

  for i = top_sep_idx - 1, 1, -1 do
    if is_separator_line(lines[i]) then
      top_sep_idx = i
      break
    end
  end

  return table.concat(vim.list_slice(lines, 1, top_sep_idx - 1), '\n')
end

local M = {}

function M.agents(opts)
  local function make_finder()
    return finders.new_table({
      results = Herdr.get_agents(),
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = string.format('%s %s %s', entry.pane_id, entry.agent_status, entry.name or 'claude'),
        }
      end,
    })
  end

  local picker = require('telescope.pickers').new(opts, {
    finder = make_finder(),
    sorter = config.generic_sorter(opts),
    previewer = require('telescope.previewers').new_termopen_previewer({
      get_command = function(entry, status)
        -- ジョブ完了時、プレビューは先頭にスクロールされたままになることがある。
        -- 直近のやり取りを見せたいので、出力が終わり次第末尾へスクロールする。
        local preview_winid = status.layout.preview and status.layout.preview.winid
        if preview_winid then
          local bufnr = vim.api.nvim_win_get_buf(preview_winid)
          vim.api.nvim_create_autocmd('TermClose', {
            buffer = bufnr,
            once = true,
            callback = function()
              vim.schedule(function()
                for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
                  pcall(vim.api.nvim_win_call, winid, function()
                    vim.cmd('normal! G')
                  end)
                end
              end)
            end,
          })
        end

        local cmd = { 'herdr', 'agent', 'read', entry.value.pane_id, '--source', 'recent-unwrapped' }

        local ok, proc = pcall(vim.system, cmd, { text = true })
        if not ok then
          return cmd
        end
        local completed = proc:wait()
        if completed.code ~= 0 or not completed.stdout or completed.stdout == '' then
          return cmd
        end

        local filtered = strip_prompt_chrome(completed.stdout)
        return { 'sh', '-c', "cat <<'HERDR_PREVIEW_EOF'\n" .. filtered .. "\nHERDR_PREVIEW_EOF\n" }
      end,
    }),
    attach_mappings = function(_, map)
      map({ 'n', 'i' }, '<CR>', function(prompt_bufnr)
        local entry = state.get_selected_entry()
        entry.value:focus()
        actions.close(prompt_bufnr)
      end)
      map({ 'n', 'i' }, '<C-l>', function(prompt_bufnr)
        local picker = state.get_current_picker(prompt_bufnr)
        picker:refresh(make_finder(), { reset_prompt = false })
      end)

      map({ 'n', 'i' }, '<C-c>', actions.nop)
      map({ 'n', 'i' }, '<C-c>c', function(prompt_bufnr)
        local picker = state.get_current_picker(prompt_bufnr)
        Herdr.spawn_agent()
        picker:refresh(make_finder(), { reset_prompt = false })
      end)
      map({ 'n', 'i' }, '<C-c>d', function(prompt_bufnr)
        local picker = state.get_current_picker(prompt_bufnr)
        local entry = state.get_selected_entry()
        entry.value:kill()
        picker:refresh(make_finder(), { reset_prompt = false })
      end)

      return true
    end,
    prompt_title = '',
    results_title = 'Agents',
    preview_title = 'Session',
    layout_strategy = 'vertical',
    layout_config = {
      preview_height = 0.8,
    },
  })

  picker:find()
end

return M
