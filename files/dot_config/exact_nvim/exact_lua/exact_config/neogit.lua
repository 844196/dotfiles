-- mappings 設定はキー割り当てのみで挙動は変更できないため、アクション関数自体をラップする
local status_actions = require('neogit.buffers.status.actions')
local CommitViewBuffer = require('neogit.buffers.commit_view')
local LogViewBuffer = require('neogit.buffers.log_view')

-- CommitView から LogView の PeekUp/PeekDown (前後のコミットへ移動しつつ CommitView を更新) を
-- 代行実行する。`<c-w>h<c-j><c-w>l` 相当を 1 キーにまとめたもの。LogView 側の実装詳細に依存する
-- キー送信ベースの間借りなので、LogView の挙動が変わると壊れる可能性がある。
local function peek_via_log_view(key)
  return function()
    if not LogViewBuffer.is_open() then
      return
    end

    LogViewBuffer.instance.buffer:win_call(
      function() vim.cmd({ cmd = 'normal', args = { vim.keycode(key) }, bang = false }) end
    )
  end
end

local commit_view_open = CommitViewBuffer.open
CommitViewBuffer.open = function(self, ...)
  local result = commit_view_open(self, ...)

  if result and result.buffer and result.buffer.handle then
    vim.keymap.set('n', '<c-j>', peek_via_log_view('<c-j>'), { buffer = result.buffer.handle })
    vim.keymap.set('n', '<c-k>', peek_via_log_view('<c-k>'), { buffer = result.buffer.handle })
  end

  return result
end

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

local function get_diff_integration()
  local viewer = require('neogit.config').get_diff_viewer()
  if viewer == 'codediff' then
    return require('neogit.integrations.codediff')
  else
    return require('neogit.integrations.diffview')
  end
end

local function claude_commit()
  local git = require('neogit.lib.git')
  local process = require('neogit.process')
  local runner = require('neogit.runner')
  local async = require('neogit.lib.async')

  vim.ui.input({ prompt = 'Claude Commit note: ' }, function(note)
    if note == nil then
      return
    end

    local cmd = { 'git', '--no-pager', '--no-optional-locks', 'claude-commit', '--no-resume' }
    if note ~= '' then
      table.insert(cmd, vim.fn.shellescape(note))
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

    -- popup 経由の呼び出しは a.void 内で実行されるため spawn_async (非同期) が使われるが、
    -- ここから直接呼ぶと非同期コンテキストが無く jobwait (同期ブロック) にフォールバックし、
    -- 実行中のコンソール表示が更新されなくなるため、明示的に非同期コンテキストを張る。
    async.void(function() runner.call(proc, { pty = true }) end)()
  end)
end

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
      builder:new_action_group('Claude'):action('C', 'Claude Commit', claude_commit)
    end,
    NeogitDiffPopup = function(builder)
      builder:action('R', 'Diff (push preview: @{u}...HEAD)', function(popup)
        popup:close()
        get_diff_integration().open('range', '@{u}...HEAD')
      end)
      builder:action('B', 'Diff (base branch remote vs HEAD)', function(popup)
        popup:close()

        local git = require('neogit.lib.git')
        local notification = require('neogit.lib.notification')

        local current = git.branch.current()
        local base = current and git.config.get('branch.' .. current .. '.base'):read()
        if not base then
          notification.error('base branch is not configured (branch.' .. tostring(current) .. '.base)')
          return
        end

        local remote = git.config.get('branch.' .. base .. '.remote'):read()
        if not remote then
          notification.error('remote is not configured (branch.' .. base .. '.remote)')
          return
        end

        get_diff_integration().open('range', remote .. '/' .. base .. '...HEAD')
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

return { claude_commit = claude_commit }
