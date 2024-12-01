return {
    "akinsho/toggleterm.nvim",
    version = '*',
    config = function()
        require("toggleterm").setup({
            size = 15,
            shade_terminals = true,
            hide_numbers = true,
            close_on_exit = true,
            auto_scroll = false,
            shell = vim.o.shell,
            float_opts = {
                border = 'curved',
                width = 130,
                height = 30,
            },
            map_opts = {
                insert = true,
                noremap = true,
                silent = true,
                desc = "Toggle Terminal"
            },
            open_mapping = [[<C-`>]],
            hide_numbers = true,
            shading_factor = '1',
            start_in_insert = true,
            persist_size = true,
            direction = 'horizontal'
        })
    end
}
