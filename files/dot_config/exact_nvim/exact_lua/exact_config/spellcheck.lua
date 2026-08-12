local M = {}

local CHECKER_NAMESPACE_NAME = 'cspell'

---@class CSpellDiagnostic : vim.Diagnostic
---@field user_data { suggestions: string[] }

---@param dir ('prev'|'next')?
---@return CSpellDiagnostic?
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
  return vim.diagnostic.jump({ namespace = checker_ns_id, wrap = false, count = dir == 'prev' and -1 or 1 }) --[[@as CSpellDiagnostic?]]
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

---@return CSpellDiagnostic?
function M.get_error()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  local diags = vim.diagnostic.get(0, { lnum = row - 1 })
  for _, diag in ipairs(diags) do
    if diag.source ~= 'cspell' then
      goto continue
    end

    if diag.col > col then
      goto continue
    end
    if diag.end_col <= col then
      goto continue
    end

    do
      return diag --[[@as CSpellDiagnostic]]
    end

    ::continue::
  end
end

-- `vim.lsp.buf.rename` はカーソル位置の識別子全体を置き換えるため、誤字部分だけの訂正文字列を渡すと識別子の残りが失われる。
---@param diag CSpellDiagnostic
---@param repl string
---@return string
local function build_full_identifier(diag, repl)
  local line = vim.api.nvim_buf_get_lines(diag.bufnr, diag.lnum, diag.lnum + 1, false)[1]

  -- lua の 1-indexed / inclusive な文字列添字に変換
  local word_start = diag.col + 1
  local word_end = diag.end_col

  local id_start = word_start
  while id_start > 1 and line:sub(id_start - 1, id_start - 1):match('[%w_]') do
    id_start = id_start - 1
  end
  local id_end = word_end
  while id_end < #line and line:sub(id_end + 1, id_end + 1):match('[%w_]') do
    id_end = id_end + 1
  end

  local prefix = line:sub(id_start, word_start - 1)
  local suffix = line:sub(word_end + 1, id_end)
  return prefix .. repl .. suffix
end

---@param diag CSpellDiagnostic
---@param repl string
local function apply_correction(diag, repl)
  -- telescope の prompt (insert mode) を閉じた直後は、insert mode 終了に伴うカーソル列の補正が非同期に (次の event loop tick で) 入ることがある。
  -- 同期的にカーソルを合わせてもその後の vim.lsp.buf.rename 側の非同期処理でずれた位置を参照してしまうため、その補正が確定してから実行されるよう 1 tick 遅らせる
  vim.schedule(function()
    vim.diagnostic.jump({ diagnostic = diag })

    local clients = vim.lsp.get_clients({ bufnr = diag.bufnr, method = 'textDocument/prepareRename' })
    local should_rename_by_ls = false
    for _, cl in ipairs(clients) do
      local params = vim.lsp.util.make_position_params(0, cl.offset_encoding)
      local res = cl:request_sync('textDocument/prepareRename', params, 1000, diag.bufnr)
      if res ~= nil and res.err == nil and res.result ~= nil then
        should_rename_by_ls = true
        break
      end
    end

    if should_rename_by_ls then
      local full_repl = build_full_identifier(diag, repl)
      vim.lsp.buf.rename(full_repl, { bufnr = diag.bufnr })
    else
      vim.api.nvim_buf_set_text(diag.bufnr, diag.lnum, diag.col, diag.end_lnum, diag.end_col, { repl })
    end
  end)
end

---@param diag CSpellDiagnostic
function M.correct(diag)
  local suggestions = diag.user_data.suggestions
  if #suggestions == 0 then
    vim.notify('No spelling suggestions at cursor', vim.log.levels.WARN)
    return
  end

  require('telescope.pickers').new(require('telescope.themes').get_cursor({ layout_config = { width = 40 } }), {
    prompt_title = 'Suggestions',
    finder = require('telescope.finders').new_table({ results = suggestions }),
    attach_mappings = function(buf)
      local acts = require('telescope.actions')

      acts.select_default:replace(function()
        local entry = require('telescope.actions.state').get_selected_entry()
        acts.close(buf)
        apply_correction(diag, entry.value)
      end)

      return true
    end,
  }):find()
end

return M
