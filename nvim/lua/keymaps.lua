-- Move line up
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true, silent = true, desc = "Move line up" })
vim.keymap.set('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true, silent = true, desc = "Move line up" })

-- Move line down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true, silent = true, desc = "Move line down" })
vim.keymap.set('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true, silent = true, desc = "Move line down" })

-- window management
vim.keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
vim.keymap.set("n", "<leader>sx", ":close<cr>") -- close current split window

vim.keymap.set("n", "<leader>to", ":tabnew<cr>") -- open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<cr>") -- close current tab
vim.keymap.set("n", "<leader>tn", ":tabn<cr>") --  go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<cr>") --  go to previous tab