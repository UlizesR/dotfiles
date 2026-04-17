local wezterm = require('wezterm')
local act     = wezterm.action

local config = wezterm.config_builder and wezterm.config_builder() or {}

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

-- Detect platform: CTRL on Linux/Windows, CMD on macOS
local is_macos = wezterm.target_triple:find("apple") ~= nil
local mod      = is_macos and "CMD" or "CTRL"

-- ── Tab title ─────────────────────────────────────────────────────────────────
wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
  local colors      = conf.resolved_palette
  local bg          = colors.tab_bar.background
  local fg          = colors.foreground
  local edge_bg     = colors.background

  if tab.is_active or hover then
    bg = colors.ansi[5]   -- Magenta for active / hovered tab
    fg = colors.background
  end

  local title = basename(tostring(tab.active_pane.current_working_dir))
  local max   = config.tab_max_width or 32
  if #title > max then
    title = wezterm.truncate_right(title, max) .. "…"
  end

  return {
    { Background = { Color = edge_bg } }, { Foreground = { Color = bg } },
    { Text = tab.tab_index == 0 and " " or "" },
    { Background = { Color = bg } },     { Foreground = { Color = fg } },
    { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
    { Text = " " .. (tab.tab_index + 1) .. ": " .. title .. " " },
    { Background = { Color = edge_bg } }, { Foreground = { Color = bg } },
    { Text = "" },
  }
end)

-- ── Right-side status bar ─────────────────────────────────────────────────────
wezterm.on("update-right-status", function(window)
  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#a9b1d6" } },
    { Text = wezterm.strftime("%Y-%m-%d  %H:%M:%S  ") },
  }))
end)

-- ── Key bindings ──────────────────────────────────────────────────────────────
local keys = {
  -- ── Panes ──────────────────────────────────────────────────────────────────
  { key = "s",          mods = mod .. "|ALT",       action = act.SplitVertical   { domain = "CurrentPaneDomain" } },
  { key = "v",          mods = mod .. "|ALT",       action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "h",          mods = mod .. "|ALT",       action = act.ActivatePaneDirection("Left")  },
  { key = "j",          mods = mod .. "|ALT",       action = act.ActivatePaneDirection("Down")  },
  { key = "k",          mods = mod .. "|ALT",       action = act.ActivatePaneDirection("Up")    },
  { key = "l",          mods = mod .. "|ALT",       action = act.ActivatePaneDirection("Right") },
  { key = "q",          mods = mod .. "|ALT",       action = act.CloseCurrentPane { confirm = true } },
  { key = "z",          mods = mod .. "|ALT",       action = act.TogglePaneZoomState },
  { key = "r",          mods = mod .. "|ALT",       action = act.RotatePanes "Clockwise" },
  { key = "R",          mods = mod .. "|ALT|SHIFT", action = act.RotatePanes "CounterClockwise" },
  { key = "Tab",        mods = mod .. "|ALT",       action = act.ActivatePaneDirection("Next") },

  -- ── Pane resize ────────────────────────────────────────────────────────────
  { key = "LeftArrow",  mods = mod .. "|SHIFT",     action = act.AdjustPaneSize { "Left",  5 } },
  { key = "RightArrow", mods = mod .. "|SHIFT",     action = act.AdjustPaneSize { "Right", 5 } },
  { key = "UpArrow",    mods = mod .. "|SHIFT",     action = act.AdjustPaneSize { "Up",    5 } },
  { key = "DownArrow",  mods = mod .. "|SHIFT",     action = act.AdjustPaneSize { "Down",  5 } },

  -- ── Tabs ───────────────────────────────────────────────────────────────────
  { key = "t",          mods = mod,                 action = act.SpawnTab("CurrentPaneDomain") },
  { key = "[",          mods = mod .. "|SHIFT",     action = act.ActivateTabRelative(-1) },
  { key = "]",          mods = mod .. "|SHIFT",     action = act.ActivateTabRelative(1)  },
  { key = "n",          mods = mod .. "|SHIFT",     action = act.ShowTabNavigator },
  { key = "w",          mods = mod .. "|SHIFT",     action = act.CloseCurrentTab { confirm = true } },

  -- ── Clipboard ──────────────────────────────────────────────────────────────
  { key = "c",          mods = mod,                 action = act.CopyTo "ClipboardAndPrimarySelection" },
  { key = "v",          mods = mod,                 action = act.PasteFrom "Clipboard" },
  { key = "c",          mods = mod .. "|SHIFT",     action = act.CopyTo "PrimarySelection" },

  -- ── Window ─────────────────────────────────────────────────────────────────
  { key = "f",          mods = mod .. "|SHIFT",     action = act.ToggleFullScreen },
  { key = "n",          mods = mod,                 action = act.SpawnWindow },
  { key = "m",          mods = mod .. "|SHIFT",     action = act.Hide },
  { key = "l",          mods = mod .. "|SHIFT",     action = act.ShowLauncher },
  { key = "Space",      mods = mod .. "|SHIFT",     action = act.QuickSelect },

  -- ── Search ─────────────────────────────────────────────────────────────────
  { key = "f",          mods = mod,                 action = act.Search { CaseInSensitiveString = "" } },
  { key = "s",          mods = mod .. "|SHIFT",     action = act.Search { CaseSensitiveString  = "" } },

  -- ── Font size ──────────────────────────────────────────────────────────────
  { key = "=",          mods = mod,                 action = act.IncreaseFontSize },
  { key = "+",          mods = mod .. "|SHIFT",     action = act.IncreaseFontSize },
  { key = "-",          mods = mod,                 action = act.DecreaseFontSize },
  { key = "0",          mods = mod,                 action = act.ResetFontSize    },

  -- ── Editing conveniences ───────────────────────────────────────────────────
  { key = "Backspace",  mods = "ALT",               action = act.SendKey { key = "w", mods = "CTRL" } }, -- delete word
  { key = "Backspace",  mods = "CTRL",              action = act.SendKey { key = "u", mods = "CTRL" } }, -- delete to BOL
  { key = "Backspace",  mods = "CMD",               action = act.SendKey { key = "u", mods = "CTRL" } }, -- macOS: delete to BOL

  -- ── Keybindings help overlay ───────────────────────────────────────────────
  -- CMD+/ (macOS) or CTRL+/ (Linux) — opens a new tab with all keybindings.
  -- '/' needs no Shift, so WezTerm receives it cleanly with no OS conflicts.
  {
    key = "/", mods = mod,
    action = act.SpawnCommandInNewTab {
      args = { os.getenv("SHELL") or "zsh", "-ic",
               "wezkeys; echo; printf 'Press Enter to close…'; read" },
    },
  },
}

-- ── Mouse bindings ────────────────────────────────────────────────────────────
local mouse_bindings = {
  -- Right-click pastes from clipboard
  {
    event  = { Down = { streak = 1, button = "Right" } },
    mods   = "NONE",
    action = act.PasteFrom "Clipboard",
  },
  -- Ctrl/Cmd+Click opens hyperlinks
  {
    event  = { Up = { streak = 1, button = "Left" } },
    mods   = is_macos and "CMD" or "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
}

-- ── Full config table ─────────────────────────────────────────────────────────
config.automatically_reload_config = true
config.enable_wayland               = true
config.disable_default_key_bindings = true

config.keys          = keys
config.mouse_bindings = mouse_bindings

-- Tab bar
config.tab_max_width                  = 32
config.use_fancy_tab_bar              = false
config.show_new_tab_button_in_tab_bar = false

-- Window
config.window_close_confirmation = "NeverPrompt"
config.window_decorations        = "RESIZE"
config.window_padding            = { left = 4, right = 4, top = 4, bottom = 4 }

-- Scrollback
config.scrollback_lines = 10000

-- Cursor
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate    = 500

-- Selection
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"
config.enable_kitty_graphics   = true

-- Launch menu
config.launch_menu = {
  { label = "Bash", args = { "bash", "-l" } },
  { label = "Zsh",  args = { "zsh",  "-l" } },
  { label = "Fish", args = { "fish", "-l" } },
}

-- Font
config.font      = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 12.0
config.line_height = 1.1

-- Font rendering (crisp on Wayland / Hyprland)
config.font_rasterizer             = "FreeType"
config.freetype_render_target      = "Normal"
config.freetype_load_target        = "Light"
config.freetype_interpreter_version = 40
config.adjust_window_size_when_changing_font_size = false

-- Color scheme + semi-transparent background
config.color_scheme = "tokyonight-storm"
config.background   = {
  {
    source  = { Color = "#24283b" },
    width   = "100%",
    height  = "100%",
    opacity = 0.9,
  },
}

return config
