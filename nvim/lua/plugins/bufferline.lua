vim.pack.add({ { src = "https://github.com/akinsho/bufferline.nvim" } }, { load = false })
 
local ok, err = pcall(function()
  require("bufferline").setup({
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp", 
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
          separator = true,
        },
      },
    },
  })
end)
if not ok then
  vim.notify(("bufferline setup failed: %s"):format(err), vim.log.levels.ERROR)
end
