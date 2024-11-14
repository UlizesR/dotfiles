local wezterm = require('wezterm');

-- Import actions
local act = wezterm.action

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then config = wezterm.config_builder() end

-- Catppuccin Mocha Color Palette in Lua
local catppuccin_mocha = {
    rosewater = "#f5e0dc",
    flamingo = "#f2cdcd",
    pink = "#f5c2e7",
    mauve = "#cba6f7",
    red = "#f38ba8",
    maroon = "#eba0ac",
    peach = "#fab387",
    yellow = "#f9e2af",
    green = "#a6e3a1",
    teal = "#94e2d5",
    sky = "#89dceb",
    sapphire = "#74c7ec",
    blue = "#89b4fa",
    lavender = "#b4befe",
    text = "#cdd6f4",
    subtext1 = "#bac2de",
    subtext0 = "#a6adc8",
    overlay2 = "#9399b2",
    overlay1 = "#7f849c",
    overlay0 = "#6c7086",
    surface2 = "#585b70",
    surface1 = "#45475a",
    surface0 = "#313244",
    base = "#1e1e2e",
    mantle = "#181825",
    crust = "#11111b"
}

local function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
    local background = catppuccin_mocha.lavender
    local foreground = catppuccin_mocha.base
    local edge_background = "#282c35"

    if tab.is_active or hover then
        background = catppuccin_mocha.sky
        foreground = catppuccin_mocha.surface2
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

config = {
    automatically_reload_config = true,

    -- Keys
    disable_default_key_bindings = true,

    keys = {

        -- Pane keybindings
        { key = "s",          mods = "CMD|ALT",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
        { key = "v",          mods = "CMD|ALT",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
        { key = "h",          mods = "CMD|ALT",      action = act.ActivatePaneDirection("Left") },
        { key = "j",          mods = "CMD|ALT",      action = act.ActivatePaneDirection("Down") },
        { key = "k",          mods = "CMD|ALT",      action = act.ActivatePaneDirection("Up") },
        { key = "l",          mods = "CMD|ALT",      action = act.ActivatePaneDirection("Right") },
        { key = "q",          mods = "CMD|ALT",      action = act.CloseCurrentPane { confirm = true } },

          -- Tab keybindings
        { key = "t",          mods = "CMD",            action = act.SpawnTab("CurrentPaneDomain") },
        { key = "[",          mods = "CMD|SHIFT",      action = act.ActivateTabRelative(-1) },
        { key = "]",          mods = "CMD|SHIFT",      action = act.ActivateTabRelative(1) },
        { key = "n",          mods = "CMD|SHIFT",      action = act.ShowTabNavigator },
        { key = "w",          mods = "CMD|SHIFT",      action = act.CloseCurrentTab { confirm = true } },

        -- Clipboard keybindings
        { key = "c",          mods = "CMD",            action = act.CopyTo "ClipboardAndPrimarySelection" },
        { key = "v",          mods = "CMD",            action = act.PasteFrom "Clipboard" },
        { key = "c",          mods = "CMD|SHIFT",      action = act.CopyTo "PrimarySelection" },

        -- Window keybindings
        { key = "f",          mods = "CMD|SHIFT",      action = act.ToggleFullScreen },

    },

    -- Tab settings 
    show_close_tab_button_in_tabs = false,

    tab_max_width = 32,
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,

    window_close_confirmation = "NeverPrompt",
    window_decorations = "RESIZE",

    -- Font settings
    font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
    font_size = 14,

    -- Colors
    color_scheme = 'Catppuccin Mocha (Gogh)',
    background = {
       {
            source = {
                Color = "#282c35"
            },
            width = "100%",
            height = "100%",
            opacity = 0.9,
        },
    },
    colors = {
        tab_bar = {
            background = 'rgba(40, 44, 53, 0.1)',
        },
        split = catppuccin_mocha.sky,
    }
}

return config
