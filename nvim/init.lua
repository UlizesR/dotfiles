-- Leader must be set before lazy.nvim loads plugins that map <leader> keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.loader.enable()

require('config.options')
require('config.lazy')   -- bootstraps lazy.nvim and loads everything in lua/plugins/
require('config.keymaps')
require('config.autocmd')
