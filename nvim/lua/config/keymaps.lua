-- mode(s), key, action (string cmd or function), description, [extra opts]
local function keymap(m, k, v, d, extra)
  local opts = vim.tbl_extend('force', { silent = true, desc = d }, extra or {})
  if opts.remap == nil then
    opts.noremap = true
  end
  vim.keymap.set(m, k, v, opts)
end

keymap('', '<Space>', '<Nop>', '')

-------------------------------------------------------------------
-- File / session
-------------------------------------------------------------------
keymap('n', '<leader>w', ':write<CR>', 'Save the current file')
keymap('n', '<leader>q', ':quit<CR>', 'Close the current window')
keymap('n', '<leader>Q', ':quit!<CR>', 'Force close without saving')
keymap('n', '<leader>v', ':edit $MYVIMRC<CR>', 'Open your init.lua for editing')

-------------------------------------------------------------------
-- Window navigation / resize
-------------------------------------------------------------------
keymap('n', '<C-h>', '<C-w>h', 'Move focus to the window on the left')
keymap('n', '<C-j>', '<C-w>j', 'Move focus to the window below')
keymap('n', '<C-k>', '<C-w>k', 'Move focus to the window above')
keymap('n', '<C-l>', '<C-w>l', 'Move focus to the window on the right')

keymap('n', '<C-Up>', ':resize +1<CR>', 'Increase window height')
keymap('n', '<C-Down>', ':resize -1<CR>', 'Decrease window height')
keymap('n', '<C-Left>', ':vertical resize -1<CR>', 'Decrease window width')
keymap('n', '<C-Right>', ':vertical resize +1<CR>', 'Increase window width')

-------------------------------------------------------------------
-- Scrolling / search
-- Note: Vim's native <C-d> ("scroll half-page down") is intentionally
-- left unbound here -- it's reassigned to multi-select in
-- plugins/multicursor.lua per the VS Code parity request below.
-------------------------------------------------------------------
keymap('n', '<C-u>', '<C-u>zz', 'Scroll up half a page, keep cursor centred')

keymap('n', 'n', 'nzzzv', 'Next search match, centred on screen')
keymap('n', 'N', 'Nzzzv', 'Previous search match, centred on screen')

-------------------------------------------------------------------
-- Clipboard / indenting / paste
-------------------------------------------------------------------
keymap('v', '<leader>y', '"+y', 'Yank selection to the system clipboard')
keymap('v', '<', '<gv', 'Indent selection left and re-select')
keymap('v', '>', '>gv', 'Indent selection right and re-select')
keymap('v', 'p', '"_dP', 'Paste over selection without losing yanked text')
keymap('x', 'p', '"_dP', 'Paste over block without losing yanked text')

-------------------------------------------------------------------
-- Terminal mode navigation
-------------------------------------------------------------------
keymap('t', '<ESC>', '<C-\\><C-n>', 'Exit terminal insert mode')
keymap('t', '<C-h>', '<C-\\><C-N><C-w>h', 'Terminal: move focus left')
keymap('t', '<C-j>', '<C-\\><C-N><C-w>j', 'Terminal: move focus down')
keymap('t', '<C-k>', '<C-\\><C-N><C-w>k', 'Terminal: move focus up')
keymap('t', '<C-l>', '<C-\\><C-N><C-w>l', 'Terminal: move focus right')

-------------------------------------------------------------------
-- Misc
-------------------------------------------------------------------
keymap('n', 'Q', '<Nop>', 'Disabled (prevents accidental Ex mode)')
keymap('n', '<C-a>', 'ggVG', 'Select all text in the file')

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

-------------------------------------------------------------------
-- VS Code parity: comment toggle (Ctrl+/)
-- Uses Neovim's built-in commenting (0.10+, gc/gcc) -- no plugin
-- needed. `remap = true` is required here: gcc/gc are themselves
-- mappings, and our own mapping's noremap default would otherwise
-- block them from expanding.
-- Terminals vary in what they send for Ctrl+/: most emit <C-_>
-- (historically the same control code); some modern ones send <C-/>
-- directly. Both are mapped so one of them will match your terminal.
-------------------------------------------------------------------
keymap('n', '<C-_>', 'gcc', 'Toggle comment (line)', { remap = true })
keymap('x', '<C-_>', 'gc', 'Toggle comment (selection)', { remap = true })
keymap('n', '<C-/>', 'gcc', 'Toggle comment (line)', { remap = true })
keymap('x', '<C-/>', 'gc', 'Toggle comment (selection)', { remap = true })

-------------------------------------------------------------------
-- VS Code parity: multi-select (Ctrl+D)
-- The actual keybind is configured in plugins/multicursor.lua, since
-- vim-visual-multi requires its keys to be set via a global variable
-- before the plugin loads -- the one plugin keymap that can't live
-- here. Flagging it so it's not surprising: <C-d> here also replaces
-- Vim's native "scroll half-page down".
-------------------------------------------------------------------

-------------------------------------------------------------------
-- VS Code parity: file tree (Ctrl+B) and terminal (Ctrl+`)
-------------------------------------------------------------------
keymap('n', '<C-b>', ':NvimTreeToggle<CR>', 'Toggle file tree (VS Code: Ctrl+B)')

-- Minimal floating terminal toggle -- no extra plugin needed. Note:
-- not every terminal emulator sends a distinguishable code for
-- Ctrl+` (backtick); this works in most modern ones (kitty, iTerm2,
-- WezTerm). If yours doesn't register it, toggleterm.nvim is the
-- common upgrade path for a more robust implementation.
local term_buf, term_win

local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    term_win = nil
    return
  end

  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  term_win = vim.api.nvim_open_win(term_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
  })

  if vim.bo[term_buf].buftype ~= 'terminal' then
    vim.fn.termopen(vim.o.shell)
  end
  vim.cmd.startinsert()
end

keymap({ 'n', 't' }, '<C-`>', toggle_terminal, 'Toggle floating terminal (VS Code: Ctrl+`)')

-------------------------------------------------------------------
-- LSP (global; harmlessly no-ops on buffers without an attached client)
-------------------------------------------------------------------
keymap('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
keymap('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
keymap('n', 'gr', vim.lsp.buf.references, 'List references')
keymap('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
keymap('n', 'K', vim.lsp.buf.hover, 'Show hover docs')
-- Intentionally project-wide: this renames every reference to the
-- symbol under the cursor across your codebase, regardless of how
-- many cursors Ctrl+D has selected. To replace only the occurrences
-- you selected with Ctrl+D, don't use this -- just type (or press `c`)
-- directly after selecting; that's vim-visual-multi's own local edit,
-- unrelated to the LSP.
keymap('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol (project-wide)')
keymap({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
keymap('n', '[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
keymap('n', ']d', vim.diagnostic.goto_next, 'Next diagnostic')
keymap('n', '<leader>k', vim.diagnostic.open_float, 'Show diagnostics for current line')

-------------------------------------------------------------------
-- Telescope: fuzzy find + grep
-------------------------------------------------------------------
keymap('n', '<leader>ff', function() require('telescope.builtin').find_files() end, 'Find files')
keymap('n', '<leader>fg', function() require('telescope.builtin').live_grep() end, 'Live grep')
keymap('n', '<leader>fb', function() require('telescope.builtin').buffers() end, 'Find open buffers')
keymap('n', '<leader>fh', function() require('telescope.builtin').help_tags() end, 'Search help tags')

-- VS Code parity: Ctrl+P quick-open, Ctrl+Shift+F project grep
-- (Ctrl+Shift+F depends on your terminal supporting distinct
-- shift+ctrl encoding -- kitty/WezTerm do, plain xterm may not).
keymap('n', '<C-p>', function() require('telescope.builtin').find_files() end, 'Find files (VS Code: Ctrl+P)')
keymap('n', '<C-S-f>', function() require('telescope.builtin').live_grep() end, 'Grep in files (VS Code: Ctrl+Shift+F)')

-------------------------------------------------------------------
-- Buffer navigation (no bufferline UI -- plain :bnext/:bprevious;
-- also VS Code-style Ctrl+Tab cycling)
-------------------------------------------------------------------
keymap('n', '<S-l>', '<Cmd>bnext<CR>', 'Go to the next buffer')
keymap('n', '<S-h>', '<Cmd>bprevious<CR>', 'Go to the previous buffer')
keymap('n', '<leader>bd', '<Cmd>bdelete<CR>', 'Close current buffer')
keymap('n', '<C-Tab>', '<Cmd>bnext<CR>', 'Next buffer (VS Code: Ctrl+Tab)')
keymap('n', '<C-S-Tab>', '<Cmd>bprevious<CR>', 'Previous buffer (VS Code: Ctrl+Shift+Tab)')

-------------------------------------------------------------------
-- Gitsigns: hunk navigation/staging (global calls; no on_attach needed)
-------------------------------------------------------------------
keymap('n', ']h', function() require('gitsigns').next_hunk() end, 'Next git hunk')
keymap('n', '[h', function() require('gitsigns').prev_hunk() end, 'Previous git hunk')
keymap('n', '<leader>hs', function() require('gitsigns').stage_hunk() end, 'Stage hunk')
keymap('n', '<leader>hr', function() require('gitsigns').reset_hunk() end, 'Reset hunk')
keymap('n', '<leader>hp', function() require('gitsigns').preview_hunk() end, 'Preview hunk')
keymap('n', '<leader>hb', function() require('gitsigns').blame_line({ full = true }) end, 'Blame current line')

-------------------------------------------------------------------
-- Debugging: nvim-dap / nvim-dap-ui, VS Code's standard debug keys
-------------------------------------------------------------------
keymap('n', '<F5>', function() require('dap').continue() end, 'Debug: Start/Continue')
keymap('n', '<F9>', function() require('dap').toggle_breakpoint() end, 'Debug: Toggle breakpoint')
keymap('n', '<F10>', function() require('dap').step_over() end, 'Debug: Step over')
keymap('n', '<F11>', function() require('dap').step_into() end, 'Debug: Step into')
keymap('n', '<S-F11>', function() require('dap').step_out() end, 'Debug: Step out')
keymap('n', '<leader>du', function() require('dapui').toggle() end, 'Debug: Toggle UI')
keymap('n', '<leader>db', function() require('dap').toggle_breakpoint() end, 'Debug: Toggle breakpoint')
