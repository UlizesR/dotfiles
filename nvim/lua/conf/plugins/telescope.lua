return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  module = "telescope",

  config = function()
    require("telescope").setup({})

    local builtin = require("telescope.builtin")
    local map = vim.keymap.set

    map("n", "<leader>ff", builtin.find_files,  { desc = "Find files by name" })
    map("n", "<leader>fg", builtin.git_files,   { desc = "Find files tracked by git" })
    map("n", "<leader>fr", builtin.live_grep,   { desc = "Search text across all files (live grep)" })
    map("n", "<leader>fb", builtin.buffers,     { desc = "List and switch between open buffers" })
    map("n", "<leader>fh", ":Telescope find_files hidden=true<CR>", { desc = "Find files including hidden dotfiles" })
  end,
}
