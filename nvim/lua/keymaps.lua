-- Move line up
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true, desc = "Move line up" })

-- Move line down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true, desc = "Move line down" })

-- Tab management
vim.keymap.set("n", "<leader>ta", ":$tabnew<CR>", { noremap = true, desc = "New tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { noremap = true, desc = "Close tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { noremap = true, desc = "Close other tabs" })
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", { noremap = true, desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", { noremap = true, desc = "Previous tab" })
vim.keymap.set("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true, desc = "Move tab to previous position" })
vim.keymap.set("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true, desc = "Move tab to next position" })

-- LSP
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format" })
vim.keymap.set('n', '<leader>fs', ':Neotree filesystem reveal left<CR>', { noremap = true, silent = true, desc = "Open/switch to the filesystem view" })
vim.keymap.set('n', '<leader>ft', ':Neotree toggle<CR>', { noremap = true, silent = true, desc = "Toggle the filesystem view" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "Show Hover" })
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to Definition" })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { noremap = true, silent = true, desc = "Show References" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { noremap = true, silent = true, desc = "Code Action" })

-- CopilotChat
vim.keymap.set({ "n", "v" }, "<leader>oc", function() require("CopilotChat").open() end, { desc = "CopilotChat - Open" })
vim.keymap.set("n", "<leader>ah", function()
    local actions = require("CopilotChat.actions")
    require("CopilotChat.integrations.telescope").pick(actions.help_actions())
end, { desc = "CopilotChat - Help actions" })
vim.keymap.set("n", "<leader>ae", "<cmd>CopilotChatExplain<cr>", { desc = "CopilotChat - Explain code" })
vim.keymap.set("n", "<leader>at", "<cmd>CopilotChatTests<cr>", { desc = "CopilotChat - Generate tests" })
vim.keymap.set("n", "<leader>ar", "<cmd>CopilotChatReview<cr>", { desc = "CopilotChat - Review code" })
vim.keymap.set("n", "<leader>aR", "<cmd>CopilotChatRefactor<cr>", { desc = "CopilotChat - Refactor code" })
vim.keymap.set("n", "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", { desc = "CopilotChat - Better Naming" })
