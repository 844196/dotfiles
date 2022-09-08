local wezterm = require "wezterm"

function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local wsl_domains = wezterm.default_wsl_domains()
for idx, dom in ipairs(wsl_domains) do
  dom.default_cwd = "~"
end

return {
  wsl_domains = wsl_domains,

  color_scheme = "iceberg-dark",
  colors = {
    split = "#0f1117",
    tab_bar = {
      background = "#161821",

      active_tab = {
        bg_color = "#161821",
        fg_color = "rgba(107, 112, 137, 0.69)",
        intensity = "Half",
        underline = "None",
        italic = false,
        strikethrough = false,
      },

      inactive_tab = {
        bg_color = "#161821",
        fg_color = "#3d435c",
        intensity = "Half",
        underline = "None",
        italic = false,
        strikethrough = false,
      },

      inactive_tab_hover = {
        bg_color = "#161821",
        fg_color = "rgba(107, 112, 137, 0.69)",
        intensity = "Half",
        underline = "None",
        italic = true,
        strikethrough = false,
      },

      new_tab = {
        bg_color = "#161821",
        fg_color = "#161821",
        italic = false
      },

      new_tab_hover = {
        bg_color = "#161821",
        fg_color = "#161821",
        italic = false
      },
    },
  },

  font = wezterm.font("UDEV Gothic 35NFLG", { weight = 600 }),
  font_size = 8,
  line_height = 1.3,

  window_decorations = "RESIZE",
  initial_rows = 67,
  initial_cols = 109,
  window_padding = {
    left = "2cell",
    right = "2cell",
    top = "1cell",
    bottom = "1cell",
  },

  default_cursor_style = "BlinkingBlock",
  cursor_blink_rate = 500,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",

  inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 1.0,
  },

  tab_bar_at_bottom = true,
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  tab_max_width = 32,
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local pwd = string.gsub(tab.active_pane.current_working_dir, '^[a-z]*://[^/]*', '')
    local shortPwd = string.gsub(string.gsub(pwd, '^/home/[^/]+', '~'), '^/Users/[^/]+', '~')

    local title = shortPwd
    if title == "~" then
      title = "~/"
    end

    if #title > max_width then
      title = basename(title)
    end

  local SUP_IDX = {"¹","²","³","⁴","⁵","⁶","⁷","⁸","⁹","¹⁰","¹¹","¹²","¹³","¹⁴","¹⁵","¹⁶","¹⁷","¹⁸","¹⁹","²⁰"}

    return {
      {
        Text = "  " .. SUP_IDX[tab.tab_index + 1] .. " " .. title .. (tab.is_active and "*" or " "),
      },
    }
  end),

  leader = { key = "t", mods = "CTRL" },
  keys = {
    { key = "r", mods = "LEADER", action = wezterm.action.ReloadConfiguration },
    { key = "v", mods = "LEADER", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
    { key = '"', mods = "LEADER|SHIFT", action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "h", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Left" } },
    { key = "j", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Down" } },
    { key = "k", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Up" } },
    { key = "l", mods = "LEADER", action = wezterm.action { ActivatePaneDirection = "Right" } },
    { key = "c", mods = "LEADER", action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
    { key = "n", mods = "LEADER", action = wezterm.action { ActivateTabRelative = 1 } },
    { key = "p", mods = "LEADER", action = wezterm.action { ActivateTabRelative = -1 } },
    { key = "[", mods = "LEADER", action = "ActivateCopyMode" },
    { key = "]", mods = "LEADER", action = wezterm.action.Paste },
    { key = "<", mods = "LEADER|SHIFT", action = wezterm.action.Multiple {
      wezterm.action.ActivateKeyTable { name = "resize_pane", one_shot = false },
      wezterm.action.AdjustPaneSize { "Left", 1 },
    } },
    { key = ">", mods = "LEADER|SHIFT", action = wezterm.action.Multiple {
      wezterm.action.ActivateKeyTable { name = "resize_pane", one_shot = false },
      wezterm.action.AdjustPaneSize { "Right", 1 },
    } },
    { key = "+", mods = "LEADER|SHIFT", action = wezterm.action.Multiple {
      wezterm.action.ActivateKeyTable { name = "resize_pane", one_shot = false },
      wezterm.action.AdjustPaneSize { "Up", 1 },
    } },
    { key = "-", mods = "LEADER", action = wezterm.action.Multiple {
      wezterm.action.ActivateKeyTable { name = "resize_pane", one_shot = false },
      wezterm.action.AdjustPaneSize { "Down", 1 },
    } },
    { key = "q", mods = "LEADER", action = wezterm.action.PaneSelect {
      alphabet = "1234567890"
    } },
  },
  key_tables = {
    resize_pane = {
      { key = "<", mods = "SHIFT", action = wezterm.action.AdjustPaneSize { "Left", 1 } },
      { key = ">", mods = "SHIFT", action = wezterm.action.AdjustPaneSize { "Right", 1 } },
      { key = "+", mods = "SHIFT", action = wezterm.action.AdjustPaneSize { "Up", 1 } },
      { key = "-", action = wezterm.action.AdjustPaneSize { "Down", 1 } },
      { key = "Escape", action = "PopKeyTable" },
    },
    copy_mode = {
      { key = "Escape", mods = "NONE", action = wezterm.action.CopyMode "Close" },
      {
        key = "Enter",
        mods = "NONE",
        action = wezterm.action.Multiple {
          { CopyTo = "ClipboardAndPrimarySelection" },
          wezterm.action.ClearSelection,
          { CopyMode = "Close" },
        },
      },
      { key = "0", mods = "NONE", action = wezterm.action.CopyMode "MoveToStartOfLine" },
      { key = "$", mods = "SHIFT", action = wezterm.action.CopyMode "MoveToEndOfLineContent" },
      { key = "h", mods = "NONE", action = wezterm.action.CopyMode "MoveLeft" },
      { key = "j", mods = "NONE", action = wezterm.action.CopyMode "MoveDown" },
      { key = "k", mods = "NONE", action = wezterm.action.CopyMode "MoveUp" },
      { key = "l", mods = "NONE", action = wezterm.action.CopyMode "MoveRight" },
      { key = "w", mods = "NONE", action = wezterm.action.CopyMode "MoveForwardWord" },
      { key = "b", mods = "NONE", action = wezterm.action.CopyMode "MoveBackwardWord" },
      { key = "Space", mods = "NONE", action = wezterm.action.CopyMode { SetSelectionMode = "Cell" } },
      { key = "v", mods = "NONE", action = wezterm.action.CopyMode { SetSelectionMode = "Cell" } },
      { key = "v", mods = "CTRL", action = wezterm.action.CopyMode { SetSelectionMode = "Block" } },
      { key = "V", mods = "SHIFT", action = wezterm.action.CopyMode { SetSelectionMode = "Line" } },
    },
  },
}
