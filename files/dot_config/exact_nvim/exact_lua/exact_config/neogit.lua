-- mappings 設定はキー割り当てのみで挙動は変更できないため、アクション関数自体をラップする
local status_actions = require('neogit.buffers.status.actions')

local function keep_focus(action_name)
  local original = status_actions[action_name]
  status_actions[action_name] = function(self)
    local fn = original(self)
    return function()
      local winid = vim.api.nvim_get_current_win()
      fn()
      if vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_set_current_win(winid)
      end
    end
  end
end

keep_focus('n_split_open')
keep_focus('n_vertical_split_open')

require('neogit').setup({
  kind = 'auto',
  treesitter_diff_highlight = true,
  word_diff_highlight = true,
  mappings = {
    status = {
      ['<Esc>'] = 'Close',
      ['<C-g>'] = 'Close',
      ['<c-s>'] = 'SplitOpen',
    },
  },
  builders = {
    NeogitCommitPopup = function(builder)
      builder:new_action_group('Claude'):action('C', 'Claude Commit', function()
        local git = require('neogit.lib.git')
        local process = require('neogit.process')
        local runner = require('neogit.runner')

        vim.ui.input({ prompt = 'Claude Commit note: ' }, function(note)
          if note == nil then
            return
          end

          local cmd = { 'git', '--no-pager', '--no-optional-locks', 'claude-commit', '--no-resume' }
          if note ~= '' then
            table.insert(cmd, note)
          end

          local proc = process.new({
            cmd = cmd,
            cwd = git.repo.worktree_root,
            env = {},
            on_error = function()
              return false
            end,
            git_hook = true,
            suppress_console = false,
            user_command = true,
          })
          proc:show_console()

          runner.call(proc, { pty = true })
        end)
      end)
    end,
    NeogitResetPopup = function(builder)
      builder:action('.', 'HEAD~    (mixed)', function()
        local git = require('neogit.lib.git')
        local notification = require('neogit.lib.notification')
        local event = require('neogit.lib.event')

        local target = 'HEAD~'
        if git.reset.mixed(target) then
          notification.info('Reset to ' .. target)
          event.send('Reset', { commit = target, mode = 'mixed' })
        else
          notification.error('Reset Failed')
        end
      end)
    end,
  },
})
