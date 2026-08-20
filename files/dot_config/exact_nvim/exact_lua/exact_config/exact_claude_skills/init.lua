--- Claude Code のスキル名を列挙する。
---
--- 列挙元 (バックエンド) は差し替え可能。どのバックエンドも同じ `ClaudeSkill[]` を返すので、
--- 利用側 (blink.cmp のソース) はどれが刺さっているかを知らない

---@class ClaudeSkill
---@field name string 名前空間付きのスキル名 (`herdr:orchestrate`)。先頭の `/` は含まない

--- 取得は非同期になりうる (CLI 版) ため、同期のバックエンドもコールバックで返す
---@alias ClaudeSkillBackend fun(callback: fun(skills: ClaudeSkill[]))

local M = {}

---@type ClaudeSkillBackend
M.backend = require('config.claude_skills.glob')

---@type ClaudeSkill[]?
local cache = nil

--- 取得中に積まれた待ち行列。CLI 版は数秒かかるので、その間の打鍵ぶんが全部ここに入る。
--- `nil` なら取得は走っていない
---@type (fun(skills: ClaudeSkill[]))[]?
local waiting = nil

--- キャッシュを捨てて取り直す。
--- 取得中に呼ばれた場合は待ち行列に積むだけで、二重には走らせない
---@param callback? fun(skills: ClaudeSkill[])
function M.refresh(callback)
  if waiting then
    if callback then
      table.insert(waiting, callback)
    end
    return
  end

  waiting = callback and { callback } or {}

  -- バックエンドが投げても待ち行列を握ったままにしない
  local ok, err = pcall(M.backend, function(skills)
    local callbacks = waiting or {}
    waiting = nil
    cache = skills
    for _, cb in ipairs(callbacks) do
      cb(skills)
    end
  end)

  if not ok then
    waiting = nil
    vim.notify('スキル一覧の取得に失敗しました: ' .. tostring(err), vim.log.levels.WARN)
  end
end

--- キャッシュがあればそれを返す。
--- 無ければ取得を開始して `nil` を返し、揃った時点で `on_ready` を呼ぶ。
--- **受け取り口は戻り値か `on_ready` のどちらか一方だけ** — 二重に候補を流さないための約束
---@param on_ready? fun(skills: ClaudeSkill[])
---@return ClaudeSkill[]?
function M.get(on_ready)
  if cache then
    return cache
  end

  M.refresh(on_ready)
  return nil
end

--- 揃ったスキル一覧をちょうど 1 回だけ渡す。
--- 補完メニューのように「まず空で返す」必要がない呼び出し側 (選択 UI など) 向け
---@param callback fun(skills: ClaudeSkill[])
function M.with(callback)
  local cached = M.get(callback)
  if cached then
    callback(cached)
  end
end

return M
