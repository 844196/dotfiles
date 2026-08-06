local M = {}

local CHECKER_NAMESPACE_NAME = 'cspell'

---@param dir ('prev'|'next')?
function M.jump(dir)
  local checker_ns_id
  for ns_id, ns in pairs(vim.diagnostic.get_namespaces()) do
    if string.match(ns.name, CHECKER_NAMESPACE_NAME) ~= nil then
      checker_ns_id = ns_id
      if ns.disabled ~= false then
        vim.diagnostic.enable(true, { ns_id = checker_ns_id })
      end
      break
    end
  end
  vim.diagnostic.jump({ namespace = checker_ns_id, wrap = false, count = dir == 'prev' and -1 or 1 })
end

function M.disable()
  local checker_ns_id
  for ns_id, ns in pairs(vim.diagnostic.get_namespaces()) do
    if string.match(ns.name, CHECKER_NAMESPACE_NAME) ~= nil then
      if ns.disabled then
        return
      end
      checker_ns_id = ns_id
      break
    end
  end
  vim.diagnostic.enable(false, { ns_id = checker_ns_id })
end

function M.toggle()
  local checker_ns_id
  local is_enabled
  for ns_id, ns in pairs(vim.diagnostic.get_namespaces()) do
    if string.match(ns.name, CHECKER_NAMESPACE_NAME) ~= nil then
      is_enabled = not ns.disabled
      checker_ns_id = ns_id
      break
    end
  end
  vim.diagnostic.enable(not is_enabled, { ns_id = checker_ns_id })
end

return M
