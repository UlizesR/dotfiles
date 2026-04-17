return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",

  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c",
        "cpp",
        "objc",
        "python",
        "rust",
        "glsl",
        "hlsl",
        "lua",
        "vim",
        "vimdoc",
        "query",
        -- "bibtex", -- optional
        -- DO NOT add "latex" here
      },

      sync_install = false,
      auto_install = false,
      ignore_install = { "latex" },

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      indent = {
        enable = true,
      },
    })
  end,
}
