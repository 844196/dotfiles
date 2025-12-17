vim.opt.fileencodings = {
  -- BOMの検出を最優先にしないと、BOM付きUTF-8ファイルが正しく認識されない
  'ucs-bom',

  -- Default
  'utf-8',

  -- Shift JIS (Required iconv)
  'shift-jis',
  'sjis',
  'cp932',
  'iso-2022-jp',

  -- System locale
  'default',

  -- 8ビットエンコーディングは一番最後に指定しなければならない
  'latin1',
}

-- 2 spaces indent (global)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0 -- i.e. Use tabstop value
vim.opt.expandtab = true

-- コマンドライン補完で大文字小文字を区別しない
vim.opt.wildignorecase = true

-- n/N検索時に末尾から先頭に戻らない
vim.opt.wrapscan = false

-- n/N検索で大文字小文字を区別しないが、大文字を含む場合は区別する
vim.opt.ignorecase = true
vim.opt.smartcase = true
