require('which-key').add({ { '<Leader>f', group = 'File' } })

local get_ivy_hermit = require('config.telescope.themes').get_ivy_hermit

-- find_files を cwd 付きで開く。何も入力されていない状態での <C-h>/<BS> は親ディレクトリへ移動、それ以外は通常の backspace
local function find_files_from(cwd, extra_opts)
  require('telescope.builtin').find_files(get_ivy_hermit(vim.tbl_extend('force', extra_opts or {}, {
    cwd = cwd,
    prompt_title = 'Find Files (' .. cwd .. ')',
    attach_mappings = function(prompt_bufnr, map)
      local function backspace_or_go_to_parent()
        if require('telescope.actions.state').get_current_line() == '' then
          require('telescope.actions').close(prompt_bufnr)
          find_files_from(vim.fs.dirname(cwd), extra_opts)
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<BS>', true, false, true), 'n', true)
        end
      end
      map('i', '<C-h>', backspace_or_go_to_parent)
      map('i', '<BS>', backspace_or_go_to_parent)
      return true
    end,
  })))
end

vim.keymap.set('n', '<Leader>ff', function()
  find_files_from(require('telescope.utils').buffer_dir())
end, { desc = 'Find file starting from the current file directory' })
vim.keymap.set({ 'n', 'x' }, '<Leader>fF', function()
  -- ビジュアルモードだったとしても gf トライで抜けてしまうため、先にフォールバックテキストを取得しておく
  local cursor = require('config.cursor')
  local default_text = cursor.region_or(cursor.cfile)

  if pcall(vim.cmd.normal, { 'gf', bang = true }) then
    return
  end

  find_files_from(require('telescope.utils').buffer_dir(), {
    default_text = default_text,
  })
end, { desc = 'Open the file under point, or find it if not found' })
vim.keymap.set('n', '<Leader>fj', '<Cmd>Oil<CR>', { desc = 'Jump to the current buffer file in oil' })
vim.keymap.set('n', '<Leader>ft', function() Snacks.explorer() end, { desc = 'Open the file tree' })
vim.keymap.set('n', '<Leader>fT', function()
  local explorer = Snacks.explorer.reveal()
  if explorer then
    explorer:focus()
  end
end, { desc = 'Reveal the current file in the file tree' })
vim.keymap.set('n', '<Leader>fr', function() require('telescope.builtin').oldfiles(get_ivy_hermit()) end, { desc = 'Open a recent file' })
vim.keymap.set('n', '<Leader>fs', '<Cmd>w<CR>', { desc = 'Save a file' })
vim.keymap.set('n', '<Leader>fS', '<Cmd>wa<CR>', { desc = 'Save all files' })

vim.keymap.set('n', '<Leader>fyn', '<Cmd>let @+ = expand("%:t")<CR>', { desc = 'Copy current file name with extension' })
vim.keymap.set('n', '<Leader>fyy', '<Cmd>let @+ = expand("%:p")<CR>', { desc = 'Copy current file absolute path' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyl', function()
  local from, to = vim.fn.line('v'), vim.fn.line('.')
  if vim.fn.mode() == 'V' and from ~= to then
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. math.min(from, to) .. '-' .. math.max(from, to))
  else
    vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. to)
  end
end, { desc = 'Copy current file absolute path with line number(s)' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyc', '<Cmd>let @+ = expand("%:p").":".line(".").":".col(".")<CR>', { desc = 'Copy current file absolute path with line and column number' })
vim.keymap.set('n', '<Leader>fyd', '<Cmd>let @+ = expand("%:p:h")<CR>', { desc = 'Copy current directory absolute path' })
vim.keymap.set('n', '<Leader>fyY', '<Cmd>let @+ = expand("%:.")<CR>', { desc = 'Copy current file path relative to the project root' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyL', function()
  local from, to = vim.fn.line('v'), vim.fn.line('.')
  if vim.fn.mode() == 'V' and from ~= to then
    vim.fn.setreg('+', vim.fn.expand('%:.') .. ':' .. math.min(from, to) .. '-' .. math.max(from, to))
  else
    vim.fn.setreg('+', vim.fn.expand('%:.') .. ':' .. to)
  end
end, { desc = 'Copy current file path relative to the project root with line number(s)' })
vim.keymap.set({ 'n', 'v' }, '<Leader>fyC', '<Cmd>let @+ = expand("%:.").":".line(".").":".col(".")<CR>', { desc = 'Copy current file path relative to the project root with line and column number' })
vim.keymap.set('n', '<Leader>fyD', '<Cmd>let @+ = expand("%:.:h")<CR>', { desc = 'Copy current directory path relative to the project root' })

vim.keymap.set('n', '<Leader>fed', function()
  local result = vim.system({ 'chezmoi', 'source-path', vim.env.MYVIMRC }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify('chezmoi source-path failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape((result.stdout:gsub('%s+$', ''))))
end, { desc = 'Open the init.lua' })
vim.keymap.set('n', '<Leader>feD', function()
  local result = vim.system({ 'chezmoi', 'source-path', vim.env.MYVIMRC }, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify('chezmoi source-path failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
    return
  end
  local source_path = result.stdout:gsub('%s+$', '')
  vim.cmd.Oil(vim.fn.fnameescape(vim.fs.dirname(source_path)))
end, { desc = 'Open the nvim dotfiles in oil' })
vim.keymap.set('n', '<Leader>feR', function()
  vim.cmd.tabnew()
  local term_buf = vim.api.nvim_get_current_buf()
  vim.fn.jobstart({ 'chezmoi', 'apply', vim.fs.dirname(vim.env.MYVIMRC) }, {
    term = true,
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(term_buf) then
            vim.api.nvim_buf_delete(term_buf, { force = true })
          end
          require('config.power').restart_with_session()
        end)
      end
    end,
  })
  vim.cmd.startinsert()
end, { desc = 'Resync the dotfiles with nvim' })
