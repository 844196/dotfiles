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
      get_command = function(entry)
        return { 'herdr', 'agent', 'read', entry.value.pane_id, '--source', 'recent-unwrapped' }
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
    layout_config = {
      preview_width = 0.8,
    },
  })

  picker:find()
end

return M
