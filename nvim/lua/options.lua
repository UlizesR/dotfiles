
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 4 -- 4 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 4 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- Search settings
opt.ignorecase = true
opt.smartcase = true

-- Window splits
opt.splitright = true
opt.splitbelow = true

-- Cursor & scrolling
opt.cursorline = true -- Highlight current line
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Appearance
opt.termguicolors = true -- True color support
opt.signcolumn = "yes" -- Always show sign column
opt.wrap = false -- Don't wrap lines

-- Editing
opt.backspace = "indent,eol,start"
opt.iskeyword:append("-") -- Consider string-string as one word

-- Files & backups
opt.undofile = true -- Persistent undo
opt.swapfile = false -- No swap files
opt.backup = false -- No backup files

-- Performance
opt.updatetime = 250 -- Faster completion (default is 4000ms)
opt.timeoutlen = 300 -- Time to wait for mapped sequence (default is 1000ms)

-- Clipboard
local uname = vim.loop.os_uname()
_G.OS = uname.sysname
_G.IS_MAC = OS == 'Darwin'
_G.IS_LINUX = OS == 'Linux'
_G.IS_WINDOWS = OS:find 'Windows' and true or false
_G.IS_WSL = IS_LINUX and uname.release:find 'Microsoft' and true or false

if _G.IS_MAC then
    opt.clipboard:append("unnamedplus") -- use system clipboard as default register
end

-- Leader key
vim.g.mapleader = " "

-- Mouse
opt.mouse = ""

-- Filetype detection for shader and compute languages
vim.filetype.add({
    extension = {
        metal = 'cpp',     -- Metal uses C++ highlighting
        cl = 'c',          -- OpenCL files (based on C99)
        mm = 'objc',       -- Objective-C++ uses Objective-C highlighting
    },
})

