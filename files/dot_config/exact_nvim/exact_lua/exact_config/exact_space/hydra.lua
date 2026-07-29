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

  -- 呼び出し元が :activate() で再度 hydra に入れるようにインスタンスを返す
  return Hydra({
    name = opts.name,
    mode = 'n',
    body = opts.body,
    heads = heads,
    config = {
      hint = {
        type = 'window',
      },
      color = opts.color or 'red',
      invoke_on_body = true,
      desc = 'Transient state',
      -- https://github.com/anuvyklack/hydra.nvim/wiki/Git#red-amaranth-and-teal-colors
      on_key = function() vim.wait(50) end,
      on_enter = function()
        require('config.number').absolute()
        require('config.cursorline').both()
      end,
      on_exit = function()
        require('config.number').rollback_state()
        require('config.cursorline').rollback_state()
      end,
    },
  })
end

return M
