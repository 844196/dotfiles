--- スキル名 (`/difit`, `/herdr:orchestrate`) を補完する blink.cmp のソース。
---
--- `vim.b.claude_prompt` が立っているバッファでだけ有効になる。
--- プロンプトバッファの filetype は `markdown` なので `sources.per_filetype` では絞れない。
---
--- `/` も `:` もキーワード文字ではないが、blink.cmp は候補ごとに置換範囲を推測するため
--- (`fuzzy/rust/keyword.rs` の `guess_keyword_range`)、`textEdit` も `filterText` も要らない。
--- むしろ `textEdit` を付けると範囲計算の責任を自前で負うことになる
local Skills = require('config.claude_skills')

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

--- プロンプトバッファ以外では、トリガ文字ごと無効になる
function source:enabled()
  return vim.b.claude_prompt == true
end

--- `:` も含めないと `/herdr:` を打った瞬間にメニューが閉じる。
--- blink.cmp はトリガ文字でもキーワード文字でもない入力で hide するため
function source:get_trigger_characters()
  return { '/', ':' }
end

--- 行頭、または直前が半角空白の `/` に続いているときだけ発火させる。
--- `foo/bar` や `~/.claude/settings.json` の途中で出てきては困る
---@param ctx blink.cmp.Context
---@return boolean
local function at_skill_position(ctx)
  local before = ctx.line:sub(1, ctx.cursor[2])

  -- カーソルより手前で最後に現れる `/` の位置 (1 始まり)
  local slash = before:match('.*()/')
  if not slash then
    return false
  end

  if slash ~= 1 and before:sub(slash - 1, slash - 1) ~= ' ' then
    return false
  end

  -- `/` 以降に空白が入ったらスキル名は終わっている
  return not before:sub(slash + 1):find('%s')
end

function source:get_completions(ctx, callback)
  if not at_skill_position(ctx) then
    callback({ items = {} })
    return
  end

  ---@param skills ClaudeSkill[]
  local function emit(skills)
    local items = {}
    for _, skill in ipairs(skills) do
      table.insert(items, {
        label = '/' .. skill.name,
        -- Function / Method にすると accept 時に `()` が付く
        kind = require('blink.cmp.types').CompletionItemKind.Text,
        insertText = '/' .. skill.name,
      })
    end
    callback({ items = items })
  end

  -- キャッシュが冷えていたら、まず空で返してから届いた分を追記する
  -- (blink.cmp は 2 回目以降の callback を追記として扱う)
  local cached = Skills.get(vim.schedule_wrap(emit))
  if cached then
    emit(cached)
  else
    callback({ items = {} })
  end
end

return source
