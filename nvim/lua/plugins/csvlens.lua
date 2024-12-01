return {
    "theKnightsOfRohan/csvlens.nvim",
    dependencies = {
        "akinsho/toggleterm.nvim"
    },
    config = function()
        require("csvlens").setup()
        end,
}
