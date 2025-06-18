
local opt = vim.opt

opt.number = true

-- tabs & indentation
opt.tabstop = 4 -- 4 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 4 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one


opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.backspace = "indent,eol,start"

-- clipboard
local uname = vim.loop.os_uname()
_G.OS = uname.sysname
_G.IS_MAC = OS == 'Darwin'
_G.IS_LINUX = OS == 'Linux'
_G.IS_WINDOWS = OS:find 'Windows' and true or false
_G.IS_WSL = IS_LINUX and uname.release:find 'Microsoft' and true or false

if _G.IS_MAC then
    opt.clipboard:append("unnamedplus") -- use system clipboard as default register
end

vim.g.mapleader = " "
opt.mouse = ""

