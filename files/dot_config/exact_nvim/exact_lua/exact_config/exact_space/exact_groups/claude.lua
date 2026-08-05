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

function Agent:kill()
  if self.status ~= 'idle' and self.status ~= 'done' then
    vim.notify('Agent busy', vim.log.levels.ERROR)
  end

  herdr({ 'pane', 'close', self.pane_id })
end

function Agent:is_visible()
  return self.tab_id == vim.env.HERDR_TAB_ID
end

function Agent:show()
  if self:is_visible() then
    return
  end

  herdr({ 'pane', 'move', self.pane_id, '--tab', vim.env.HERDR_TAB_ID, '--split', 'right', '--target-pane', vim.env.HERDR_PANE_ID, '--no-focus' })

  self.tab_id = vim.env.HERDR_TAB_ID
end

function Agent:hide()
  if not self:is_visible() then
    return
  end

  local hide = herdr({ 'pane', 'move', self.pane_id, '--new-tab', '--no-focus' })

  self.tab_id = assert(hide.result.move_result.created_tab.tab_id) --[[@as string]]
end

function Agent:focus()
  herdr({ 'agent', 'focus', self.name })
end

function Agent:toggle_visibility()
  if self:is_visible() then
    self:hide()
  else
    self:show()
  end
end

function Agent:send_to_prompt(prompt)
  herdr({ 'pane', 'send-text', self.pane_id, prompt })
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
    agent:show()
    agent:focus()
  end
end, {
  desc = 'Switch to Claude pane',
})

vim.keymap.set('x', '<Leader>$di', function()
  local agent = Agent.find()
  if agent then
    agent:show()
    agent:send_to_prompt(require('config.cursor').region_or('', { multiline = 'KEEP' }))
    agent:focus()
  end
end, {
  desc = 'Insert selected text to Claude prompt',
})
