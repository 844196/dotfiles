local Hydra = require('hydra')

local M = {}

-- git.lua の passthrough head 計算でキー集合を参照するため export する
M.exit_heads = {
  { '<Esc>', nil, { exit = true, desc = false } },
  { '<C-g>', nil, { exit = true, desc = false } },
  { 'q', nil, { exit = true, desc = false } },
}

function M.create(opts)
  local heads = {}
  for _, h in ipairs(opts.heads) do heads[#heads + 1] = h end
  for _, h in ipairs(M.exit_heads) do heads[#heads + 1] = h end

  Hydra({
    mode = 'n',
    body = opts.body,
    heads = heads,
    config = {
      hint = {
        type = 'window',
        show_name = false,
      },
      color = opts.color or 'red',
      invoke_on_body = true,
      desc = 'Transient state',
    },
  })
end

return M
