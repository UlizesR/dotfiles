return {
  "sainnhe/edge",
  lazy     = false,
  priority = 1000,
  config = function()
    vim.g.edge_style = "aura"
    vim.g.edge_background = "dark"
    vim.cmd("colorscheme edge")
  end,
}
