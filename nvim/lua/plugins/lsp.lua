local keymaps = require("config.keymaps")

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp_lsp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- This core autocommand monitors when Neovim links a Language Server to an active editing window.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("NativeLspMaps", { clear = true }),
  callback = function(args)
    keymaps.on_lsp_attach(args.buf)
  end,
})

-- ------------------------------------------------------------------------
-- C / C++ / Objective-C
-- ------------------------------------------------------------------------
vim.lsp.config.clangd = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
  capabilities = capabilities,
}
vim.lsp.enable("clangd")

-- ------------------------------------------------------------------------
-- Rust (clippy runs via rust-analyzer's own checkOnSave, no separate linter)
-- ------------------------------------------------------------------------
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
    },
  },
}
vim.lsp.enable("rust_analyzer")

-- ------------------------------------------------------------------------
-- Assembly (NASM/GAS/GO) -- `cargo install asm-lsp`
-- ------------------------------------------------------------------------
vim.lsp.config.asm_lsp = {
  cmd = { "asm-lsp" },
  filetypes = { "asm", "vmasm" },
  root_markers = { ".asm-lsp.toml", ".git" },
  capabilities = capabilities,
}
vim.lsp.enable("asm_lsp")

-- ------------------------------------------------------------------------
-- Lua
-- ------------------------------------------------------------------------
vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".git", ".luarc.json" },
  capabilities = capabilities,
  settings = {
    Lua = { runtime = { version = "LuaJIT" } },
  },
}
vim.lsp.enable("lua_ls")

-- ------------------------------------------------------------------------
-- Python (ruff handles linting separately -- see plugins.linter)
-- ------------------------------------------------------------------------
vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { ".git", "pyproject.toml", "setup.py" },
  capabilities = capabilities,
}
vim.lsp.enable("pyright")

-- ------------------------------------------------------------------------
-- LaTeX (chktex handles linting separately -- see plugins.linter)
-- ------------------------------------------------------------------------
vim.lsp.config.texlab = {
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "bib" },
  root_markers = { ".git", ".latexmkrc", "texlabroot" },
  capabilities = capabilities,
}
vim.lsp.enable("texlab")

-- ------------------------------------------------------------------------
-- Markdown (markdownlint handles linting separately -- see plugins.linter)
-- ------------------------------------------------------------------------
vim.lsp.config.marksman = {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".git", "marksman.toml" },
  capabilities = capabilities,
}
vim.lsp.enable("marksman")

-- ------------------------------------------------------------------------
-- TOML
-- ------------------------------------------------------------------------
vim.lsp.config.taplo = {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_markers = { ".git", "taplo.toml" },
  capabilities = capabilities,
}
vim.lsp.enable("taplo")

-- ------------------------------------------------------------------------
-- JSON -- `npm i -g vscode-langservers-extracted`
-- ------------------------------------------------------------------------
vim.lsp.config.jsonls = {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  capabilities = capabilities,
}
vim.lsp.enable("jsonls")

-- ------------------------------------------------------------------------
-- QML -- ships with Qt Declarative; binary may be named qmlls or qmlls6
-- ------------------------------------------------------------------------
vim.lsp.config.qmlls = {
  cmd = { "qmlls" },
  filetypes = { "qml" },
  root_markers = { ".git" },
  capabilities = capabilities,
}
vim.lsp.enable("qmlls")
