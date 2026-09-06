-- mode(s), key, action (string cmd or function), description, [extra opts]
local function keymap(m, k, v, d, extra)
  local opts = vim.tbl_extend("force", { silent = true, desc = d }, extra or {})
  if opts.remap == nil then
    opts.noremap = true
  end
  vim.keymap.set(m, k, v, opts)
end

local M = {}

keymap("n", "<leader>r", function()
  vim.cmd("silent! wa")

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf):match("NvimTree_") then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.cmd.restart()
end, "Hot Restart Neovim")

keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", "Find Files")
keymap("n", "<C-a>", "ggVG", "Select all text in the file")

-------------------------------------------------------------------
-- Debugging (nvim-dap / nvim-dap-ui)
-------------------------------------------------------------------
keymap("n", "<leader>db", function() require("dap").toggle_breakpoint() end, "Toggle breakpoint")
keymap("n", "<leader>dc", function() require("dap").continue() end, "Debug: continue/start")
keymap("n", "<leader>di", function() require("dap").step_into() end, "Debug: step into")
keymap("n", "<leader>do", function() require("dap").step_over() end, "Debug: step over")
keymap("n", "<leader>dO", function() require("dap").step_out() end, "Debug: step out")
keymap("n", "<leader>dr", function() require("dap").repl.toggle() end, "Debug: toggle REPL")
keymap("n", "<leader>du", function() require("dapui").toggle() end, "Debug: toggle UI")

-------------------------------------------------------------------
-- File tree (nvim-tree)
-------------------------------------------------------------------
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", "Toggle Nvim Tree")
keymap("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", "Reveal current file in the tree")
keymap("n", "<leader>tr", "<cmd>NvimTreeRefresh<cr>", "Refresh the file tree")

-------------------------------------------------------------------
-- Bufferline navigation
-------------------------------------------------------------------
keymap("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
keymap("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
keymap("n", "<leader>bp", "<cmd>BufferLinePick<cr>", "Pick buffer")
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", "Close current buffer")

keymap("n", "<leader>bmn", "<cmd>BufferLineMoveNext<cr>", "Move buffer to next position")
keymap("n", "<leader>bmp", "<cmd>BufferLineMovePrev<cr>", "Move buffer to previous position")

-------------------------------------------------------------------
-- Window navigation / resize
-------------------------------------------------------------------
keymap('n', '<C-h>', '<C-w>h', 'Move focus to the window on the left')
keymap('n', '<C-j>', '<C-w>j', 'Move focus to the window below')
keymap('n', '<C-k>', '<C-w>k', 'Move focus to the window above')
keymap('n', '<C-l>', '<C-w>l', 'Move focus to the window on the right')

-------------------------------------------------------------------
-- VS Code parity: line duplication (Alt+Shift+Up/Down)
-------------------------------------------------------------------
keymap('n', '<A-S-Up>', ':t.-1<CR>', 'Duplicate current line above')
keymap('n', '<A-S-Down>', ':t.<CR>', 'Duplicate current line below')
keymap('v', '<A-S-Up>', ":<C-u>'<,'>t'<-1<CR>gv", 'Duplicate selection above')
keymap('v', '<A-S-Down>', ":<C-u>'<,'>t'><CR>gv", 'Duplicate selection below')

-------------------------------------------------------------------
-- VS Code parity: line movement (Alt+Up/Down)
-------------------------------------------------------------------
keymap('n', '<A-Up>', ':m .-2<CR>==', 'Move current line up')
keymap('n', '<A-Down>', ':m .+1<CR>==', 'Move current line down')
keymap('v', '<A-Up>', ":m '<-2<CR>gv=gv", 'Move selected lines up')
keymap('v', '<A-Down>', ":m '>+1<CR>gv=gv", 'Move selected lines down')

keymap('n', '<C-_>', 'gcc', 'Toggle comment (line)', { remap = true })
keymap('x', '<C-_>', 'gc', 'Toggle comment (selection)', { remap = true })
keymap('n', '<C-/>', 'gcc', 'Toggle comment (line)', { remap = true })
keymap('x', '<C-/>', 'gc', 'Toggle comment (selection)', { remap = true })

keymap('v', 'p', '"_dP', 'Paste over selection without losing yanked text')
keymap('x', 'p', '"_dP', 'Paste over block without losing yanked text')

function M.on_lsp_attach(bufnr)
  local buf_opts = { buffer = bufnr }
  keymap("n", "gd", vim.lsp.buf.definition, "Go to definition", buf_opts)
  keymap("n", "K", vim.lsp.buf.hover, "Show hover info", buf_opts)
  keymap('n', 'gr', vim.lsp.buf.references, 'List references')
  keymap('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
  keymap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol", buf_opts)
  keymap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action", buf_opts)
end

return M
