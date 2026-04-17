return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  module = "telescope",

  config = function()
    require("telescope").setup({
      defaults = {
        -- Show hidden files in file pickers
        file_ignore_patterns = { "^%.git/" },
      },
      pickers = {
        keymaps = {
          -- Show all modes in the keymap picker
          modes = { "n", "v", "i", "x", "o", "t", "c" },
          show_plug = false,   -- hide internal <Plug> mappings
        },
      },
    })

    local builtin = require("telescope.builtin")
    local map     = vim.keymap.set

    -- ── File / search ──────────────────────────────────────────────────────────
    map("n", "<leader>ff", builtin.find_files,  { desc = "Find files by name" })
    map("n", "<leader>fg", builtin.git_files,   { desc = "Find files tracked by git" })
    map("n", "<leader>fr", builtin.live_grep,   { desc = "Search text across all files (live grep)" })
    map("n", "<leader>fb", builtin.buffers,     { desc = "List and switch between open buffers" })
    map("n", "<leader>fh", function()
      builtin.find_files({ hidden = true })
    end, { desc = "Find files including hidden dotfiles" })

    -- ── Keymaps: flat searchable list of every registered keymap ───────────────
    -- This shows ALL keymaps (core + plugins) in one flat Telescope list.
    -- Use <leader>fk or :Keymaps to open it.
    map("n", "<leader>fk", builtin.keymaps, { desc = "Browse all keymaps (flat list)" })
    vim.api.nvim_create_user_command("Keymaps", builtin.keymaps, { desc = "Browse all keymaps" })
  end,
}
