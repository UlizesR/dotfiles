vim.pack.add({ { src = "https://github.com/folke/tokyonight.nvim" } }, { load = false })

require("tokyonight").setup({
  transparent = true,
  styles = {
    sidebars = "transparent", -- nvim-tree
    floats = "transparent",   -- Telescope, LSP hover, diagnostic floats
  },
  on_highlights = function(hl, c)
    hl.WinSeparator = { fg = c.blue, bg = "NONE" }

    hl.NvimTreeWinSeparator = { fg = c.blue, bg = "NONE" }

  end,
})

vim.cmd.colorscheme("tokyonight")
