return {
    'nvim-lualine/lualine.nvim',
    config = function()
        local line = require('lualine')
        line.setup({
            options = {
                icons_enabled = true,
                theme = 'catppuccin',
                component_separators = { right = '✧ .*'},
                section_separators = {left = "", right = ""},
            },
            sections = {
                lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
                lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
            },
            extensions = {
                'mason',
                'lazy',
            },
        })
    end,
}
