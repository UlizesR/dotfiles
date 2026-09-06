vim.pack.add({
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
}, { load = false })

-- Shows which language server is attached to the current buffer
local function lsp_client_name()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  return "󰒓 " .. clients[1].name
end

local ok, err = pcall(function()
  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "tokyonight",
      component_separators = { left = "✧", right = "✧" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
      lualine_b = {
        "branch",
        "diff",
      },
      lualine_c = {},
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          sections = { "error", "warn" },
          symbols = { error = "󰅚 ", warn = "󰀪 " },
          colored = true,
          always_visible = true,
        },
        lsp_client_name,
      },
      lualine_y = { "searchcount", "selectioncount", "filetype" },
      lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
    },
    extensions = {
      "nvim-tree",
    },
  })
end)
if not ok then
  vim.notify(("lualine setup failed: %s"):format(err), vim.log.levels.ERROR)
end
