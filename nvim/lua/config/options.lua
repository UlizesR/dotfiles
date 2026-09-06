-- Must be set before any keymaps that use <leader>.
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.signcolumn = 'yes'          -- reserve gutter space so gitsigns/diagnostics don't shift text
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 200            -- faster gitsigns/diagnostic updates
vim.opt.scrolloff = 8
vim.opt.fillchars = {
  vert = "│",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}

vim.o.winbar = "%#WinSeparator#" .. string.rep("─", 300)

-- Filetype disambiguation:
-- .m defaults to Matlab in vanilla Neovim; force Objective-C as requested.
vim.g.filetype_m = 'objc'
vim.opt.completeopt = "menu,menuone,noselect,popup"
-- Trim a stock runtime plugin we never use.
vim.g.loaded_tutor_mode_plugin = 1
