
local opt = vim.opt

opt.number = true

opt.expandtab = true
opt.autoindent = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

--opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

vim.g.mapleader = " "
opt.mouse = ""

