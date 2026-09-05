return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy    = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    -- Disable netrw
    vim.g.loaded_netrw       = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      sort_by = "case_sensitive",

      view = {
        width      = 30,
        side       = "left",
        number     = false,
        relativenumber = false,
        signcolumn = "yes",
      },

      renderer = {
        highlight_git          = true,
        highlight_opened_files = "icon",
        root_folder_label      = ":~:s?$?/..?",
        indent_width           = 2,
        indent_markers = {
          enable        = true,
          inline_arrows = true,
          icons = {
            corner = "└",
            edge   = "│",
            item   = "│",
            bottom = "─",
            none   = " ",
          },
        },
        icons = {
          git_placement = "before",
          glyphs = {
            default  = "",
            symlink  = "",
            bookmark = "󰆤",
            modified = "●",
            folder = {
              arrow_closed = "",
              arrow_open   = "",
              default      = "󰉋",
              open         = "󰝰",
              empty        = "󰉖",
              empty_open   = "󰷏",
              symlink      = "󰉒",
              symlink_open = "󰝰",
            },
            git = {
              unstaged  = "✗",
              staged    = "✓",
              unmerged  = "",
              renamed   = "➜",
              untracked = "★",
              deleted   = "",
              ignored   = "◌",
            },
          },
        },
      },

      update_focused_file = {
        enable      = true,
        update_root = true,
      },

      filters = { dotfiles = false },

      git = {
        enable            = true,
        show_on_dirs      = true,
        show_on_open_dirs = true,
      },

      actions = {
        open_file = {
          quit_on_open  = false,
          resize_window = true,
        },
      },
    })

    -- ── Key mappings ────────────────────────────────────────────────────────────
    local map = vim.keymap.set

    map("n", "<leader>e", ":NvimTreeToggle<CR>",   { desc = "Open/close the file tree" })
    map("n", "<leader>E", ":NvimTreeFindFile<CR>", { desc = "Reveal current file in the tree" })
    map("n", "<leader>r", ":NvimTreeRefresh<CR>",  { desc = "Refresh the file tree" })

    -- Smart focus toggle: jump between tree and editor without closing the tree.
    -- If the tree is closed it will be opened first.
    map("n", "<C-e>", function()
      local view = require("nvim-tree.view")
      if view.is_visible() then
        if view.is_buf_valid(vim.api.nvim_get_current_buf()) then
          -- Currently IN the tree → jump back to the previous editor window
          vim.cmd("wincmd p")
        else
          -- Currently in editor → jump to the tree window
          view.focus()
        end
      else
        vim.cmd("NvimTreeOpen")
      end
    end, { desc = "Toggle focus between file tree and editor" })

    -- Auto-close tree when it's the last window
    vim.api.nvim_create_autocmd("BufEnter", {
      nested   = true,
      callback = function()
        if #vim.api.nvim_list_wins() == 1
          and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil
        then
          vim.cmd("quit")
        end
      end,
    })
  end,
}
