return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    configs = true,
    config = function()
        local pair = require('nvim-autopairs')
        pair.setup({
            disable_filetype = { "TelescopePrompt", "spectre_panel" },
            disable_in_macro = true,
        })
    end,

}
