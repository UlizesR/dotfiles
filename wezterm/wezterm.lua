local wezterm = require('wezterm');

-- Import actions
local act = wezterm.action

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then config = wezterm.config_builder() end

local function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
    local colors = conf.resolved_palette
    local background = colors.tab_bar.background
    local foreground = colors.foreground
    local edge_background = colors.background

    if tab.is_active or hover then
        background = colors.ansi[5] -- Cyan/Magenta for active tab
        foreground = colors.background
    end
    local edge_foreground = background

    -- set the title to the current open file or directory
    local pane = tab.active_pane
    local cwd = pane.current_working_dir
    local cwd_string = tostring(cwd)
    local title = basename(cwd_string)

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    local max = config.tab_max_width
    if #title > max then
        title = wezterm.truncate_right(title, max) .. "…"
    end

    return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = tab.tab_index == 0 and " " or "" },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
        { Text = " " .. (tab.tab_index + 1) .. ": " .. title .. " " },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = "" },
    }
end)

-- if OS is macOS, set CMD as the mod key
-- otherwise, set CTRL as the mod key
local mod_key = "CTRL"
local is_macos = wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin"
if is_macos then
    mod_key = "CMD"
end

config = {
    automatically_reload_config = true,

    -- Enable Wayland for Hyprland (disable if using X11)
    enable_wayland = true,

    -- Keys
    disable_default_key_bindings = true,

    keys = {

        -- Pane keybindings
        { key = "s",          mods = mod_key .. "|ALT",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
        { key = "v",          mods = mod_key .. "|ALT",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
        { key = "h",          mods = mod_key .. "|ALT",      action = act.ActivatePaneDirection("Left") },
        { key = "j",          mods = mod_key .. "|ALT",      action = act.ActivatePaneDirection("Down") },
        { key = "k",          mods = mod_key .. "|ALT",      action = act.ActivatePaneDirection("Up") },
        { key = "l",          mods = mod_key .. "|ALT",      action = act.ActivatePaneDirection("Right") },
        { key = "q",          mods = mod_key .. "|ALT",      action = act.CloseCurrentPane { confirm = true } },
        -- Pane resizing
        { key = "LeftArrow",  mods = mod_key .. "|SHIFT",    action = act.AdjustPaneSize { "Left", 5 } },
        { key = "RightArrow", mods = mod_key .. "|SHIFT",    action = act.AdjustPaneSize { "Right", 5 } },
        { key = "UpArrow",    mods = mod_key .. "|SHIFT",    action = act.AdjustPaneSize { "Up", 5 } },
        { key = "DownArrow",  mods = mod_key .. "|SHIFT",    action = act.AdjustPaneSize { "Down", 5 } },
        -- Pane zoom (temporary fullscreen for pane)
        { key = "z",          mods = mod_key .. "|ALT",      action = act.TogglePaneZoomState },
        -- Pane rotation
        { key = "r",          mods = mod_key .. "|ALT",      action = act.RotatePanes "Clockwise" },
        { key = "R",          mods = mod_key .. "|ALT|SHIFT", action = act.RotatePanes "CounterClockwise" },
        -- Cycle through panes
        { key = "Tab",        mods = mod_key .. "|ALT",      action = act.ActivatePaneDirection("Next") },

          -- Tab keybindings
        { key = "t",          mods = mod_key,                  action = act.SpawnTab("CurrentPaneDomain") },
        { key = "[",          mods = mod_key .. "|SHIFT",      action = act.ActivateTabRelative(-1) },
        { key = "]",          mods = mod_key .. "|SHIFT",      action = act.ActivateTabRelative(1) },
        { key = "n",          mods = mod_key .. "|SHIFT",      action = act.ShowTabNavigator },
        { key = "w",          mods = mod_key .. "|SHIFT",      action = act.CloseCurrentTab { confirm = true } },

        -- Clipboard keybindings
        { key = "c",          mods = mod_key,                  action = act.CopyTo "ClipboardAndPrimarySelection" },
        { key = "v",          mods = mod_key,                  action = act.PasteFrom "Clipboard" },
        { key = "c",          mods = mod_key .. "|SHIFT",      action = act.CopyTo "PrimarySelection" },

        -- Window keybindings
        { key = "f",          mods = mod_key .. "|SHIFT",      action = act.ToggleFullScreen },
        { key = "n",          mods = mod_key,                  action = act.SpawnWindow },
        { key = "m",          mods = mod_key .. "|SHIFT",      action = act.Hide },
        -- Launch menu
        { key = "l",          mods = mod_key .. "|SHIFT",      action = act.ShowLauncher },
        -- Search
        { key = "f",          mods = mod_key,                  action = act.Search { CaseInSensitiveString = "" } },
        { key = "s",          mods = mod_key .. "|SHIFT",      action = act.Search { CaseSensitiveString = "" } },
        -- Quick select mode (vim-like selection)
        { key = "Space",      mods = mod_key .. "|SHIFT",      action = act.QuickSelect },
        
        -- Zoom keybindings
        { key = "=",          mods = mod_key,                  action = act.IncreaseFontSize },
        { key = "+",          mods = mod_key .. "|SHIFT",      action = act.IncreaseFontSize },
        { key = "-",          mods = mod_key,                  action = act.DecreaseFontSize },
        { key = "0",          mods = mod_key,                  action = act.ResetFontSize },

        -- Terminal editing conveniences
        -- Alt+Backspace: delete previous word
        { key = "Backspace",  mods = "ALT",                   action = act.SendKey { key = "w", mods = "CTRL" } },
        -- Ctrl+Backspace: delete to start of line
        { key = "Backspace",  mods = "CTRL",                  action = act.SendKey { key = "u", mods = "CTRL" } },
        -- Cmd+Backspace (macOS): delete to start of line
        { key = "Backspace",  mods = "CMD",                   action = act.SendKey { key = "u", mods = "CTRL" } },

    },

    -- Tab settings 
    tab_max_width = 32,
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,

    window_close_confirmation = "NeverPrompt",
    window_decorations = "RESIZE",
    
    -- Window padding
    window_padding = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4,
    },
    
    -- Scrollback buffer (increase from default 3500)
    scrollback_lines = 10000,
    
    -- Cursor settings
    default_cursor_style = "BlinkingBlock",
    cursor_blink_rate = 500,
    
    -- Selection settings
    selection_word_boundary = " \t\n{}[]()\"'`,;:",
    
    -- Enable hyperlinks
    enable_kitty_graphics = true,
    
    -- Launch menu (quick access to common commands)
    launch_menu = {
        {
            label = "Bash",
            args = { "bash", "-l" },
        },
        {
            label = "Zsh",
            args = { "zsh", "-l" },
        },
        {
            label = "Fish",
            args = { "fish", "-l" },
        },
    },

    -- Font settings (optimized for crisp rendering on Wayland/Hyprland)
    font = wezterm.font("JetBrains Mono", { 
        weight = "Regular",
    }),
    font_size = 12.0,
    line_height = 1.1,
    
    -- Font rendering options for maximum sharpness
    font_rasterizer = "FreeType",
    
    -- FreeType settings for sharp rendering
    freetype_render_target = "Normal",  -- Normal target for greyscale
    freetype_load_target = "Light",
    freetype_interpreter_version = 40,
    
    -- Disable text blurring effects
    adjust_window_size_when_changing_font_size = false,

    -- Colors
    color_scheme = 'tokyonight-storm',
    background = {
       {
            source = {
                Color = "#24283b"
            },
            width = "100%",
            height = "100%",
            opacity = 0.9,
        },
    },
    
    -- Mouse bindings
    mouse_bindings = {
        -- Right click paste
        {
            event = { Down = { streak = 1, button = "Right" } },
            mods = "NONE",
            action = act.PasteFrom "Clipboard",
        },
        -- Ctrl+Click to open hyperlinks
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "CTRL",
            action = act.OpenLinkAtMouseCursor,
        },
    },
}

-- Status bar (right side) - must be outside config table
wezterm.on("update-right-status", function(window, pane)
    local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
    window:set_right_status(wezterm.format({
        { Foreground = { Color = "#a9b1d6" } },
        { Text = date },
    }))
end)

return config
