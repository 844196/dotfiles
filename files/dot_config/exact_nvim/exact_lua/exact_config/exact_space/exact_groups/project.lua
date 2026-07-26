require('which-key').add({ { '<Leader>p', group = 'Project' } })

vim.keymap.set('n', '<Leader>pf', '<Cmd>Telescope find_files<CR>', { desc = 'Find file' })
vim.keymap.set({ 'n', 'x' }, '<Leader>pF', function()
  local util = require('config.space.util')
  local mode = vim.fn.mode()
  local was_visual = mode == 'v' or mode == 'V' or mode == '\22'
  local ok = pcall(vim.cmd.normal, { 'gf', bang = true })
  if ok then return end
  require('telescope.builtin').find_files({
    default_text = was_visual and util.visual_selection() or vim.fn.expand('<cfile>'),
  })
end, { desc = 'Open the file under point, or find it based on path around point if not found' })
vim.keymap.set('n', '<Leader>pd', function()
  require('telescope.builtin').find_files({
    prompt_title = 'Find Directory',
    find_command = { 'fd', '--type', 'd', '--strip-cwd-prefix', '--hidden', '--no-ignore-vcs', '--exclude', '.git', '--exclude', 'node_modules' },
    entry_maker = function(line)
      local icon, hl = require('mini.icons').get('directory', line)
      return {
        value = line,
        display = function(entry)
          return icon .. ' ' .. entry.value, { { { 0, #icon }, hl } }
        end,
        ordinal = line,
      }
    end,
    attach_mappings = function(_, _)
      local actions = require('telescope.actions')
      actions.select_default:replace(function(prompt_bufnr)
        local entry = require('telescope.actions.state').get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd.Oil(vim.fn.fnameescape(entry.value))
      end)
      return true
    end,
  })
end, { desc = 'Find directory and open it in oil' })
vim.keymap.set('n', '<Leader>pD', '<Cmd>Oil .<CR>', { desc = 'Open project root in oil' })
vim.keymap.set('n', '<Leader>pr', function() require('telescope.builtin').oldfiles({ only_cwd = true }) end, { desc = 'Open a recent file' })
