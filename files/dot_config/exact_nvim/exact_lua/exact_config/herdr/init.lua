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

---@class HerdrPaneSkeleton
---@field pane_id string
---@field tab_id string
---@field workspace_id string

---@alias HerdrPaneCurrentResponse { result: { pane: HerdrPaneSkeleton } }

---@alias HerdrPaneSplitResponse { result: { pane: { pane_id: string } } }

---@alias HerdrAgentListResponse { result: { agents: HerdrAgentSkeleton[] } }

---@alias HerdrAgentGetResponse { result: { agent: HerdrAgentSkeleton } }

---@alias HerdrAgentStartResponse { result: { agent: HerdrAgentSkeleton } }

---@class HerdrError
---@field code string?
---@field message string

--- エラーコードごとの人間向けの文面。ここに無いコードは herdr のメッセージをそのまま見せる
---@type table<string, string>
local ERROR_MESSAGES = {
  agent_blocked = 'Agent is waiting on a dialog; answer it before sending',
  agent_name_taken = 'Agent name is already taken',
  agent_not_ready = 'Agent pane is not ready; it may be waiting on a trust dialog',
  agent_pane_busy = 'Agent pane is busy; wait for the running command to finish',
}

--- herdr はエラー時、エラー JSON を stderr に出して終了コード 1 を返す
---@param stderr string?
---@return HerdrError
local function parse_error(stderr)
  local fallback = stderr and stderr ~= '' and stderr or 'herdr failed'

  local ok, decoded = pcall(vim.json.decode, stderr or '')
  if not ok or type(decoded) ~= 'table' or type(decoded.error) ~= 'table' then
    return { message = fallback }
  end

  local err = decoded.error
  return { code = err.code, message = ERROR_MESSAGES[err.code] or err.message or fallback }
end

---@param args string[]
---@return { [string]: any }? res, HerdrError? err
local function try_herdr(args)
  table.insert(args, 1, 'herdr')

  local rv = vim.system(args, { text = true }):wait()
  if rv.code ~= 0 then
    return nil, parse_error(rv.stderr)
  end

  local stdout = rv.stdout
  if stdout == nil or stdout == '' then
    return {}
  end

  return assert(vim.json.decode(stdout))
end

---@param args string[]
---@return { [string]: any }
local function herdr(args)
  local res, err = try_herdr(args)
  if err then
    error(err.message, 0)
  end

  return assert(res)
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
  -- pane send-text は blocked のペインにも素通しで届くため、送る側で確認する。
  -- 自身が持つ agent_status は取得してから選択するまでの間に古くなっているので取り直す
  local res = herdr({ 'agent', 'get', self.pane_id }) --[[@as HerdrAgentGetResponse]]
  if res.result.agent.agent_status == 'blocked' then
    error(ERROR_MESSAGES.agent_blocked, 0)
  end

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

---@return HerdrPaneSkeleton
function M.get_current_pane()
  local res = herdr({ 'pane', 'current' }) --[[@as HerdrPaneCurrentResponse]]
  return res.result.pane
end

---@return HerdrAgent
function M.spawn_agent()
  local split_res = herdr({ 'pane', 'split', '--current', '--cwd', vim.fn.getcwd(), '--direction', 'right', '--no-focus' }) --[[@as HerdrPaneSplitResponse]]

  local start_res, err = try_herdr({ 'agent', 'start', 'nvim' .. vim.fn.strftime('%Y%m%d%H%M%S'), '--kind', 'claude', '--pane', split_res.result.pane.pane_id })
  if err then
    -- 起動できなくてもペインは生きているので、ダイアログに答えられるようフォーカスを渡す
    if err.code == 'agent_not_ready' then
      pcall(herdr, { 'pane', 'focus', '--current', '--direction', 'right' })
    end

    error(err.message, 0)
  end
  ---@cast start_res HerdrAgentStartResponse

  return HerdrAgent.new(start_res.result.agent)
end

return M
