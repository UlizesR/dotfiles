return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local config = require("nvim-treesitter.configs")
            config.setup({
                auto_install = true,
                ensured_installed = {
                    "c",
                    "cpp",
                    "lua",
                    "python",
                    "vim",
                    "gitignore",
                    "json",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    }
}
