local M = {}

---@param dir ('prev'|'next')?
function M.jump(dir)
  local codebook_ns_id
  for ns_id, ns in pairs(vim.diagnostic.get_namespaces()) do
    if string.match(ns.name, 'codebook') ~= nil then
      codebook_ns_id = ns_id
      if ns.disabled ~= false then
        vim.diagnostic.enable(true, { ns_id = codebook_ns_id })
      end
      break
    end
  end
  vim.diagnostic.jump({ namespace = codebook_ns_id, wrap = false, count = dir == 'prev' and -1 or 1 })
end

function M.disable()
  local codebook_ns_id
  for ns_id, ns in pairs(vim.diagnostic.get_namespaces()) do
    if string.match(ns.name, 'codebook') ~= nil then
      if ns.disabled then
        return
      end
      codebook_ns_id = ns_id
      break
    end
  end
  vim.diagnostic.enable(false, { ns_id = codebook_ns_id })
end

function M.toggle()
  local codebook_ns_id
  local is_codebook_enabled
  for ns_id, ns in pairs(vim.diagnostic.get_namespaces()) do
    if string.match(ns.name, 'codebook') ~= nil then
      is_codebook_enabled = not ns.disabled
      codebook_ns_id = ns_id
      break
    end
  end
  vim.diagnostic.enable(not is_codebook_enabled, { ns_id = codebook_ns_id })
end

return M
