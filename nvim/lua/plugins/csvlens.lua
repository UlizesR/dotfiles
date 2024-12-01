return {
    "theKnightsOfRohan/csvlens.nvim",
    dependencies = {
        "akinsho/toggleterm.nvim"
    },
    config = function()
        require("csvlens").setup()
        vim.keymap.set('n', '<leader>cvl', ':Csvlens<CR>', { noremap = true, silent = true, desc = 'Open CsvLens' })
    end,
}
