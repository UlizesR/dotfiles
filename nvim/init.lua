-- ==========================================================================
-- ENTRY POINT
-- ==========================================================================
vim.g.start_time = vim.fn.reltime()
vim.loader.enable()

require("vim._core.ui2").enable({})

require("config.options")
require("config.keymaps")
require("config.autocmd")
require("config.diagnostics")

require("plugins.lsp")
require("plugins.linter")
require("plugins.colorscheme")
require("plugins.filetree")
require("plugins.fzf")
require("plugins.gitsigns")
require("plugins.statusline")
require("plugins.bufferline")
