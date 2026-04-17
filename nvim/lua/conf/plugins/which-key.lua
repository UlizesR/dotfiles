return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.setup({
      preset = "modern",
      delay  = 400,
      icons  = { mappings = true },
    })

    -- Group labels shown in the which-key popup when you pause after a prefix
    wk.add({
      -- Prefix groups
      { "<leader>f", group = "Find (Telescope)" },

      -- File tree (defined in tree.lua)
      { "<leader>e", desc = "Open/close the file tree" },
      { "<leader>E", desc = "Reveal current file in the tree" },
      { "<leader>r", desc = "Refresh the file tree" },
      { "<C-e>",     desc = "Toggle focus between file tree and editor" },

      -- Keymap browser (defined in telescope.lua)
      { "<leader>fk", desc = "Browse all keymaps (flat list)" },

      -- LSP (defined in lsp.lua — buffer-local, shown here for reference)
      { "K",    desc = "Show docs for symbol under cursor" },
      { "gd",   desc = "Go to definition" },
      { "gD",   desc = "Go to declaration" },
      { "gi",   desc = "Go to implementation" },
      { "go",   desc = "Go to type definition" },
      { "gr",   desc = "List all references to symbol" },
      { "gs",   desc = "Show function signature help" },
      { "<F2>", desc = "Rename symbol under cursor" },
      { "<F4>", desc = "Show available code actions" },
    })
  end,
}
