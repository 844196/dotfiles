---@alias HerdrAgentStatus
---| 'idle'
---| 'working'
---| 'blocked'
---| 'done'
---| 'unknown'

---@class HerdrAgentData
---@source https://herdr.dev/docs/cli-reference/
---@field name string?
---@field workspace_id string
---@field tab_id string
---@field pane_id string
---@field agent_status HerdrAgentStatus

---@class Agent
---@field private name string
---@field private workspace_id string
---@field private tab_id string
---@field private pane_id string
---@field private status HerdrAgentStatus
local Agent = {}
Agent.__index = Agent

---@private
---@package
---@param data HerdrAgentData
function Agent.new(data)
  return setmetatable({
    name = assert(data.name),
    workspace_id = data.workspace_id,
    tab_id = data.tab_id,
    pane_id = data.pane_id,
    status = data.agent_status,
  }, Agent)
end

---@param args string[]
---@return { [string]: any }
local function herdr(args)
  table.insert(args, 1, 'herdr')

  local rv = vim.system(args, { text = true }):wait()
  if rv.code ~= 0 then
    error(rv.stderr)
  end

  local stdout = rv.stdout
  if stdout == nil or stdout == '' then
    return {}
  end

  return assert(vim.json.decode(stdout))
end

---@return Agent?
function Agent.find()
  local agents = assert(herdr({ 'agent', 'list' }).result.agents) --[=[@as HerdrAgentData[]]=]
  for _, a in ipairs(agents) do
    if a.workspace_id == vim.env.HERDR_WORKSPACE_ID and a.name and a.name:find('^nvim[0-9]+$') then
      return Agent.new(a)
    end
  end
end

---@return Agent
function Agent.spawn()
  local split = herdr({ 'pane', 'split', '--current', '--direction', 'right', '--no-focus' })
  local splitted_pane_id = assert(split.result.pane.pane_id) --[[@as string]]

  -- Avoid "agent target pane {pane_id} is not an available shell"
  vim.wait(500)

  local spawn = herdr({ 'agent', 'start', 'nvim' .. tostring(vim.fn.getpid()), '--kind', 'claude', '--pane', splitted_pane_id })
  local spawned = assert(spawn.result.agent) --[[@as HerdrAgentData]]

  return Agent.new(spawned)
end

---@return nil
function Agent:kill()
  if self.status ~= 'idle' and self.status ~= 'done' then
    vim.notify('Agent busy', vim.log.levels.ERROR)
  end

  herdr({ 'pane', 'close', self.pane_id })
end

---@return boolean
function Agent:is_visible()
  return self.tab_id == vim.env.HERDR_TAB_ID
end

---@return Agent
function Agent:show()
  if self:is_visible() then
    return self
  end

  herdr({ 'pane', 'move', self.pane_id, '--tab', vim.env.HERDR_TAB_ID, '--split', 'right', '--target-pane', vim.env.HERDR_PANE_ID, '--no-focus' })
  self.tab_id = vim.env.HERDR_TAB_ID

  return self
end

---@return Agent
function Agent:hide()
  if not self:is_visible() then
    return self
  end

  local hide = herdr({ 'pane', 'move', self.pane_id, '--new-tab', '--no-focus' })
  self.tab_id = assert(hide.result.move_result.created_tab.tab_id) --[[@as string]]

  return self
end

---@return Agent
function Agent:focus()
  herdr({ 'agent', 'focus', self.name })
  return self
end

---@return Agent
function Agent:toggle_visibility()
  return self:is_visible() and self:hide() or self:show()
end

---@return Agent
function Agent:send_to_prompt(prompt)
  herdr({ 'pane', 'send-text', self.pane_id, prompt })
  return self
end

vim.keymap.set('n', '<Leader>$ds', function()
  local agent = Agent.find()
  if agent then
    agent:show()
  else
    agent = Agent.spawn()
  end

  agent:focus()
end, {
  desc = 'Start new session',
})

vim.keymap.set('n', '<Leader>$dq', function()
  local agent = Agent.find()
  if agent then
    agent:kill()
  end
end, {
  desc = 'Stop current session',
})

vim.keymap.set('n', '<Leader>$dt', function()
  local agent = Agent.find()
  if agent then
    agent:toggle_visibility()
  end
end, {
  desc = 'Toggle Claude pane',
})

vim.keymap.set('n', '<Leader>$db', function()
  local agent = Agent.find()
  if not agent then
    return
  end

  if agent:is_visible() then
    agent:focus()
  else
    agent:show():focus()
  end
end, {
  desc = 'Switch to Claude pane',
})

vim.keymap.set('x', '<Leader>$di', function()
  local agent = Agent.find()
  if agent then
    local region = require('config.cursor').region_or('', { multiline = 'KEEP' })
    agent:show():send_to_prompt(region):focus()
  end
end, {
  desc = 'Insert selected text to Claude prompt',
})

vim.keymap.set({ 'n', 'x' }, '<Leader>$dp', function()
  local Buffer = require('config.buffer')

  local buf = Buffer.find_or_create('*claude-prompt*', function(buf)
    Buffer.ephemeralize(buf)
    vim.bo[buf].filetype = 'markdown'

    vim.keymap.set('n', 'q', '<Cmd>close!<CR>', { buf = buf })
    vim.keymap.set('n', '<Leader>mcs', function()
      local agent = Agent.find() or Agent.spawn()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      if #lines == 1 and lines[1] == '' then
        return
      end

      agent:show():send_to_prompt(table.concat(lines, '\n')):focus()

      vim.api.nvim_buf_delete(buf, { force = true })
    end, {
      desc = 'Send to Claude prompt',
      buf = buf,
    })
  end)

  local mode = vim.fn.mode()
  if mode == 'v' or mode == 'V' then
    local region_start, region_end = vim.fn.getpos('v'), vim.fn.getpos('.')
    local from_ln, to_ln = math.min(region_start[2], region_end[2]), math.max(region_start[2], region_end[2])
    local from_col = (function()
      if region_start[2] < region_end[2] then
        return region_start[3]
      elseif region_start[2] > region_end[2] then
        return region_end[3]
      else
        if region_start[3] < region_end[3] then
          return region_start[3]
        else
          return region_end[3]
        end
      end
    end)()

    ---@type string[]
    local prompt = {}

    local ln = (function()
      if from_ln == to_ln then
        return mode == 'V' and from_ln or (from_ln .. ':' .. from_col)
      else
        return mode == 'V' and (from_ln .. '-' .. to_ln) or (from_ln .. ':' .. from_col)
      end
    end)()
    table.insert(prompt, Buffer.path() .. ':' .. ln)

    if to_ln - from_ln <= 10 then
      table.insert(prompt, '```' .. vim.bo.filetype)
      for _, l in ipairs(vim.fn.getregion(region_start, region_end, { type = mode })) do
        table.insert(prompt, l)
      end
      table.insert(prompt, '```')
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if #lines == 1 and lines[1] == '' then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, prompt)
    else
      table.insert(prompt, 1, '')
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, prompt)
    end
  end

  local winid = vim.fn.bufwinid(buf)
  if winid == -1 then
    vim.cmd.vsplit()
    vim.api.nvim_set_current_buf(buf)
  else
    vim.api.nvim_set_current_win(winid)
  end
end, {
  desc = 'Open prompt buffer',
})
