local options = {
  -- Files & history
  backup      = false,
  writebackup = false,
  swapfile    = false,
  undofile    = true,
  undodir     = os.getenv("HOME") .. "/.cache/nvim/undodir",

  -- Editing
  clipboard    = "unnamedplus",
  expandtab    = true,
  shiftwidth   = 4,
  tabstop      = 4,
  smartindent  = true,
  list         = true,   -- show whitespace characters

  -- Search
  hlsearch  = true,
  incsearch = true,
  ignorecase = true,
  smartcase  = true,

  -- UI
  number         = true,
  relativenumber = false,
  numberwidth    = 4,
  cursorline     = false,
  signcolumn     = "yes",
  wrap           = false,
  showmode       = false,
  showtabline    = 2,
  pumheight      = 10,
  cmdheight      = 2,
  termguicolors  = true,
  conceallevel   = 0,
  scrolloff      = 4,
  sidescrolloff  = 4,

  -- Splits
  splitbelow = true,
  splitright = true,

  -- Performance
  timeoutlen = 1000,
  updatetime = 300,

  -- Encoding
  fileencoding = "utf-8",

  completeopt = { "menuone", "noselect" },
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.opt.shortmess:append("c")
vim.cmd("autocmd BufEnter * set formatoptions-=cro")

-- File-type specific indentation
vim.api.nvim_create_augroup("FileTypeSpecific", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group   = "FileTypeSpecific",
  pattern = { "lua" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop    = 2
  end,
})

-- Shader / compute filetype detection
vim.filetype.add({
  extension = {
    metal = "cpp",
    cl    = "c",
    mm    = "objc",
  },
})
