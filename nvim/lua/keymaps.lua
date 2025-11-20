-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Move lines up/down
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true, silent = true, desc = "Move line up" })

vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true, silent = true, desc = "Move line down" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal width & height" })
vim.keymap.set("n", "<leader>sx", ":close<cr>", { desc = "Close current split" })

-- Tab management
vim.keymap.set("n", "<leader>to", ":tabnew<cr>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", ":tabclose<cr>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", ":tabn<cr>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", ":tabp<cr>", { desc = "Go to previous tab" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })