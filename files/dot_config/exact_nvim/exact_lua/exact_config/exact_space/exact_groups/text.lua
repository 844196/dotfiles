require('which-key').add({ { '<Leader>x', group = 'Text' } })

vim.keymap.set({ 'n', 'x' }, '<Leader>xo', require('config.keymap_actions').open, { desc = 'Open' })

-- case
local function case(t)
  return function()
    require('textcase')[vim.fn.mode() == 'v' and 'operator' or 'current_word'](t)
  end
end
vim.keymap.set({ 'n', 'x' }, '<Leader>xic', case('to_camel_case'), { desc = 'lowerCamelCase' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xiC', case('to_pascal_case'), { desc = 'UpperCamelCase' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xi-', case('to_dash_case'), { desc = 'kebab-case' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xik', '<Leader>xi-', { desc = 'kebab-case', remap = true })
vim.keymap.set({ 'n', 'x' }, '<Leader>xi_', case('to_snake_case'), { desc = 'snake_case' })
vim.keymap.set({ 'n', 'x' }, '<Leader>xiu', '<Leader>xi_', { desc = 'snake_case', remap = true })
vim.keymap.set({ 'n', 'x' }, '<Leader>xiU', case('to_constant_case'), { desc = 'CONSTANT_CASE' })

local case_methods = {
  'to_camel_case',
  'to_pascal_case',
  'to_snake_case',
  'to_constant_case',
  'to_dash_case',
}

local function detect_case(word)
  if word:find('-', 1, true) then
    return 'to_dash_case'
  elseif word:find('_', 1, true) then
    return word == word:upper() and 'to_constant_case' or 'to_snake_case'
  elseif word == word:upper() then
    return 'to_constant_case'
  elseif word:match('^%u') then
    return 'to_pascal_case'
  else
    return 'to_camel_case'
  end
end

-- 'iskeyword' が '-' を含まないため、素の `viw` だとケバブケースの語境界を
-- ダッシュの手前までしか拾えない。選択直前だけ 'iskeyword' に '-' を加える。
local function select_word_including_dash()
  ---@type vim.context.mods
  local ctx = { bo = { iskeyword = vim.bo.iskeyword .. ',-' } }
  vim._with(ctx, function() vim.cmd('normal! viw') end)
end

local function cycle_case()
  local cursor = require('config.cursor')
  local word = cursor.region_or(function()
    select_word_including_dash()
    return cursor.region_or(cursor.cword)
  end)
  if word == '' then
    return
  end

  local current = detect_case(word)
  local index = 1
  for i, c in ipairs(case_methods) do
    if c == current then
      index = i
      break
    end
  end
  local next_method = case_methods[index % #case_methods + 1]
  require('textcase').operator(next_method)
end

require('config.hydra').create({
  name = 'Case',
  mode = { 'n', 'x' },
  body = '<Leader>xi',
  invoke_on_body = false,
  color = 'red',
  heads = {
    { 'i', cycle_case, { desc = 'Cycle' } },
  },
})
