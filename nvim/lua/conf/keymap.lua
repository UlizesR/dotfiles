local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader
vim.g.mapleader      = " "
vim.g.maplocalleader = " "
map("", "<Space>", "<Nop>", opts)

-- ── File / session ────────────────────────────────────────────────────────────
map("n", "<leader>w", ":write<CR>",         { desc = "Save the current file" })
map("n", "<leader>q", ":quit<CR>",          { desc = "Close the current window" })
map("n", "<leader>Q", ":quit!<CR>",         { desc = "Force close without saving" })
map("n", "<leader>v", ":edit $MYVIMRC<CR>", { desc = "Open your init.lua for editing" })

-- ── Window navigation ─────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Move focus to the window on the left" })
map("n", "<C-j>", "<C-w>j", { desc = "Move focus to the window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move focus to the window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move focus to the window on the right" })

-- Resize splits
map("n", "<C-Up>",    ":resize +1<CR>",          { desc = "Increase window height" })
map("n", "<C-Down>",  ":resize -1<CR>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  ":vertical resize -1<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +1<CR>", { desc = "Increase window width" })

-- ── Scrolling ─────────────────────────────────────────────────────────────────
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half a page, keep cursor centred" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half a page, keep cursor centred" })

-- ── Search ────────────────────────────────────────────────────────────────────
map("n", "n", "nzzzv", { desc = "Next search match, centred on screen" })
map("n", "N", "Nzzzv", { desc = "Previous search match, centred on screen" })

-- ── Buffers ───────────────────────────────────────────────────────────────────
map("n", "<S-l>", ":bnext<CR>",     { desc = "Go to the next open buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Go to the previous open buffer" })

-- ── Clipboard ─────────────────────────────────────────────────────────────────
map("v", "<leader>y", '"+y', { desc = "Yank selection to the system clipboard" })

-- ── Indenting ─────────────────────────────────────────────────────────────────
map("v", "<", "<gv", { desc = "Indent selection left and re-select" })
map("v", ">", ">gv", { desc = "Indent selection right and re-select" })

-- ── Move lines ────────────────────────────────────────────────────────────────
map("v", "<A-j>", ":m '>+1<CR>gv=gv",  { desc = "Move selected lines down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",  { desc = "Move selected lines up" })
map("x", "<A-j>", ":move '>+1<CR>gv=gv", { desc = "Move selected block down" })
map("x", "<A-k>", ":move '<-2<CR>gv=gv", { desc = "Move selected block up" })

-- Duplicate current line
map("n", "<A-S-Down>", ":t.<CR>",   { desc = "Duplicate current line below" })
map("n", "<A-S-Up>",   ":t.-1<CR>", { desc = "Duplicate current line above" })

-- ── Paste without clobbering register ─────────────────────────────────────────
map("v", "p", '"_dP', { desc = "Paste over selection without losing yanked text" })
map("x", "p", '"_dP', { desc = "Paste over block without losing yanked text" })

-- ── Terminal ──────────────────────────────────────────────────────────────────
map("t", "<ESC>",  "<C-\\><C-n>",       { silent = true, desc = "Exit terminal insert mode" })
map("t", "<C-h>",  "<C-\\><C-N><C-w>h", { silent = true, desc = "Terminal: move focus left" })
map("t", "<C-j>",  "<C-\\><C-N><C-w>j", { silent = true, desc = "Terminal: move focus down" })
map("t", "<C-k>",  "<C-\\><C-N><C-w>k", { silent = true, desc = "Terminal: move focus up" })
map("t", "<C-l>",  "<C-\\><C-N><C-w>l", { silent = true, desc = "Terminal: move focus right" })
map("n", "<A-h>",  ":below term<CR>i",  { desc = "Open a terminal split below" })

-- ── Misc ──────────────────────────────────────────────────────────────────────
map("n", "Q",         "<Nop>",  { desc = "Disabled (prevents accidental Ex mode)" })
map("n", "<C-a>",     "ggVG",   { desc = "Select all text in the file" })
map("n", "<leader>k", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Show diagnostics for current line" })

-- ── Which-key ─────────────────────────────────────────────────────────────────
map("n", "<leader>?", ":WhichKey<CR>", { desc = "Browse all keymaps" })
