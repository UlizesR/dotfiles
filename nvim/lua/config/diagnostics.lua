local icons = {
  [vim.diagnostic.severity.ERROR] = "󰅚",
  [vim.diagnostic.severity.WARN] = "󰀪",
  [vim.diagnostic.severity.INFO] = "󰋽",
  [vim.diagnostic.severity.HINT] = "󰌶",
}

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = { text = icons },
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = function(diagnostic)
      return icons[diagnostic.severity] or "●"
    end,
  },
  float = {
    border = "rounded",
    source = true,
  },
})
