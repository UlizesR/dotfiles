return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function ()
        local neo = require("neo-tree")
        neo.setup({
            window = {
                width = 40,
                position = 'left',
            },
            close_if_last_window = true,
            popup_border_style = "rounded",
            enable_git_status = true,
            filesystem = {
                filtered_items = {
                    hide_hidden = false,
                    visible = true,
                    hide_dotfile = false,
                    show_hidden_count = true,
                    never_show = { ".exe" } -- lol
                }
            },
        })
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end
}
