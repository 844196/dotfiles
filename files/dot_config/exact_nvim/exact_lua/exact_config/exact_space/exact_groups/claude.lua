local Herdr = require('config.herdr')

vim.keymap.set('n', '<Leader>$ds', function()
  local agents = Herdr.get_agents()

  if #agents > 1 or (#agents == 1 and ((agents[1].workspace_id ~= vim.env.HERDR_WORKSPACE_ID) or (agents[1].tab_id ~= vim.env.HERDR_TAB_ID))) then
    require('config.herdr.telescope').agents()
    return
  end

  local agent
  if #agents == 0 then
    agent = Herdr.spawn_agent()
  else
    agent = agents[1]
  end

  agent:focus()
end, {
  desc = 'Start new session',
})

vim.keymap.set('n', '<Leader>$dl', function() require('config.herdr.telescope').agents() end, { desc = 'List sessions' })

vim.keymap.set({ 'n', 'x' }, '<Leader>$dp', function()
  local Buffer = require('config.buffer')

  local buf = Buffer.find_or_create('*claude-prompt*', function(buf)
    Buffer.ephemeralize(buf)
    vim.bo[buf].filetype = 'markdown'

    vim.keymap.set('n', 'q', '<Cmd>close!<CR>', { buf = buf })
    vim.keymap.set('n', '<Leader>mcs', function()
      ---@param a HerdrAgent
      local send = function(a)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        if #lines == 1 and lines[1] == '' then
          return
        end

        a:send_text(table.concat(lines, '\n')):focus()

        local win = vim.fn.bufwinid(buf)
        local normal_wins = vim.tbl_filter(function(w) return vim.api.nvim_win_get_config(w).relative == '' end, vim.api.nvim_tabpage_list_wins(0))
        if #normal_wins > 1 then
          vim.api.nvim_win_close(win, true)
        else
          vim.api.nvim_win_call(win, function() vim.cmd('buffer #') end)
        end
      end

      local agents = Herdr.get_agents()

      if #agents > 1 or (#agents == 1 and ((agents[1].workspace_id ~= vim.env.HERDR_WORKSPACE_ID) or (agents[1].tab_id ~= vim.env.HERDR_TAB_ID))) then
        require('config.herdr.telescope').agents({
          attach_mappings = function(_, map)
            map({ 'n', 'i' }, '<CR>', function(prompt_bufnr)
              local actions = require('telescope.actions')
              local state = require('telescope.actions.state')
              local entry = state.get_selected_entry()
              send(entry.value)
              actions.close(prompt_bufnr)
            end)
            map({ 'n', 'i' }, '<C-c>c', function(prompt_bufnr)
              local actions = require('telescope.actions')
              actions.close(prompt_bufnr)
              send(Herdr.spawn_agent())
            end)
            return true
          end,
        })
        return
      end

      local agent
      if #agents == 0 then
        agent = Herdr.spawn_agent()
      else
        agent = agents[1]
      end

      send(agent)
    end, {
      desc = 'Send to Claude prompt',
      buf = buf,
    })
  end)

  local mode = vim.fn.mode()
  local with_snippet = mode == 'v' or mode == 'V'

  if with_snippet then
    local region_start, region_end = vim.fn.getpos('v'), vim.fn.getpos('.')
    local from_ln, to_ln = math.min(region_start[2], region_end[2]), math.max(region_start[2], region_end[2])
    local from_col = (function()
      if region_start[2] < region_end[2] then
        return region_start[3]
      elseif region_start[2] > region_end[2] then
        return region_end[3]
      else
        if region_start[3] < region_end[3] then
          return region_start[3]
        else
          return region_end[3]
        end
      end
    end)()

    ---@type string[]
    local prompt = {}

    local ln = (function()
      if from_ln == to_ln then
        return mode == 'V' and from_ln or (from_ln .. ':' .. from_col)
      else
        return mode == 'V' and (from_ln .. '-' .. to_ln) or (from_ln .. ':' .. from_col)
      end
    end)()
    table.insert(prompt, Buffer.path() .. ':' .. ln)

    if to_ln - from_ln <= 10 then
      table.insert(prompt, '```' .. vim.bo.filetype)
      for _, l in ipairs(vim.fn.getregion(region_start, region_end, { type = mode })) do
        table.insert(prompt, l)
      end
      table.insert(prompt, '```')
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if #lines == 1 and lines[1] == '' then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, prompt)
    else
      table.insert(prompt, 1, '')
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, prompt)
    end
  end

  local winid = vim.fn.bufwinid(buf)
  if winid == -1 then
    if with_snippet then
      vim.cmd.vsplit()
    end
    vim.api.nvim_set_current_buf(buf)
  else
    vim.api.nvim_set_current_win(winid)
  end

  if with_snippet then
    vim.cmd.normal({ 'G', bang = true })
  end
end, {
  desc = 'Open prompt buffer',
})
