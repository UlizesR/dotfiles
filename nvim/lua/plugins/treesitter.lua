return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local config = require("nvim-treesitter.configs")
            config.setup({
                auto_install = true,
                ensure_installed = {
                    "c",
                    "cpp",
                    "objc",
                    "glsl",
                    "hlsl",
                    "lua",
                    "python",
                    "vim",
                    "vimdoc",
                    "gitignore",
                    "json",
                    "markdown",
                    "markdown_inline",
                    "bash",
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    }
}
