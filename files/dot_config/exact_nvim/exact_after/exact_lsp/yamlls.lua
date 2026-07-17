---@module "vim.lsp"
---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      -- 組み込みのスキーマストアを無効化
      schemaStore = { enable = false, url = '' },
      schemas = require('schemastore').yaml.schemas(),
    },
  },
}
