---@alias HerdrAgentStatus
---| 'idle'
---| 'working'
---| 'blocked'
---| 'done'
---| 'unknown'

---@class HerdrAgentSkeleton
---@source https://herdr.dev/docs/cli-reference/
---@field name string?
---@field workspace_id string
---@field tab_id string
---@field pane_id string
---@field cwd string
---@field agent_status HerdrAgentStatus

---@alias HerdrPaneSplitResponse { result: { pane: { pane_id: string } } }

---@alias HerdrAgentListResponse { result: { agents: HerdrAgentSkeleton[] } }

---@alias HerdrAgentStartResponse { result: { agent: HerdrAgentSkeleton } }

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

---@class HerdrAgent : HerdrAgentSkeleton
local HerdrAgent = {}
HerdrAgent.__index = HerdrAgent

---@param skel HerdrAgentSkeleton
---@return HerdrAgent
function HerdrAgent.new(skel)
  return setmetatable({
    name = skel.name,
    workspace_id = skel.workspace_id,
    tab_id = skel.tab_id,
    pane_id = skel.pane_id,
    cwd = skel.cwd,
    agent_status = skel.agent_status,
  }, HerdrAgent)
end

function HerdrAgent:focus()
  herdr({ 'agent', 'focus', self.pane_id })
  return self
end

function HerdrAgent:send_text(txt)
  herdr({ 'pane', 'send-text', self.pane_id, txt })
  return self
end

function HerdrAgent:kill()
  if self.agent_status ~= 'idle' and self.agent_status ~= 'done' then
    error('Agent busy')
  end

  herdr({ 'pane', 'close', self.pane_id })
end

local M = {}

---@return HerdrAgent[]
function M.get_agents()
  local res = herdr({ 'agent', 'list' }) --[[@as HerdrAgentListResponse]]
  return vim.tbl_map(HerdrAgent.new, res.result.agents)
end

---@return HerdrAgent
function M.spawn_agent()
  local split_res = herdr({ 'pane', 'split', '--current', '--direction', 'right', '--no-focus' }) --[[@as HerdrPaneSplitResponse]]

  -- Avoid "agent target pane {pane_id} is not an available shell"
  vim.wait(500)

  local start_res = herdr({ 'agent', 'start', 'nvim' .. vim.fn.strftime('%Y%m%d%H%M%S'), '--kind', 'claude', '--pane', split_res.result.pane.pane_id }) --[[@as HerdrAgentStartResponse]]

  return HerdrAgent.new(start_res.result.agent)
end

return M
