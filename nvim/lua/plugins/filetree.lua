vim.pack.add({
  { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
}, { load = true })

local ok, err = pcall(function()
  require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
      width = 30,
      side = "left",
      number = false,
      relativenumber = false,
      signcolumn = "yes",
    },
    renderer = {
      highlight_git = true,
      highlight_opened_files = "icon",
      root_folder_label = ":~:s?$?/..?",
      indent_width = 2,
      indent_markers = {
        enable = true,
        inline_arrows = true,
        icons = {
          corner = "└",
          edge = "│",
          item = "│",
          bottom = "─",
          none = " ",
        },
      },
      icons = {
        git_placement = "before",
        glyphs = {
          default = "",
          symlink = "",
          bookmark = "󰆤",
          modified = "●",
          folder = {
            arrow_closed = "",
            arrow_open = "",
            default = "󰉋",
            open = "󰝰",
            empty = "󰉖",
            empty_open = "󰷏",
            symlink = "󰉒",
            symlink_open = "󰝰",
          },
          git = {
            unstaged = "✗",
            staged = "✓",
            unmerged = "",
            renamed = "➜",
            untracked = "★",
            deleted = "",
            ignored = "◌",
          },
        },
      },
    },
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    filters = { dotfiles = false },
    git = {
      enable = true,
      show_on_dirs = true,
      show_on_open_dirs = true,
    },
    actions = {
      open_file = {
        quit_on_open = false,
        resize_window = true,
      },
    },
  })
end)
if not ok then
  vim.notify(("nvim-tree setup failed: %s"):format(err), vim.log.levels.ERROR)
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("NvimTreeAutoClose", { clear = true }),
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
      vim.cmd("quit")
    end
  end,
})

