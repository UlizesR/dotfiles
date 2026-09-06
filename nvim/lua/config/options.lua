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

-- Filetype disambiguation:
-- .m defaults to Matlab in vanilla Neovim; force Objective-C as requested.
vim.g.filetype_m = 'objc'

-- No Neovim tooling (treesitter/LSP/lint) exists for Metal Shading
-- Language -- treat .metal files as C++ so you at least get reasonable
-- highlighting and clangd support, since MSL is a C++-derived syntax.
vim.filetype.add({ extension = { metal = 'cpp' } })

vim.opt.autocomplete = true

