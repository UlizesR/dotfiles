vim.pack.add({ { src = "https://github.com/mfussenegger/nvim-lint" } }, { load = false })

local ok, lint = pcall(require, "lint")
if not ok then
  vim.notify(("nvim-lint failed to load: %s"):format(lint), vim.log.levels.ERROR)
  return
end

lint.linters_by_ft = {
  python = { "ruff" },
  lua = { "luacheck" },
  c = { "cppcheck" },
  cpp = { "cppcheck" },
  markdown = { "markdownlint" },
  tex = { "chktex" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
  callback = function()
    local lint_ok, lint_err = pcall(lint.try_lint)
    if not lint_ok then
      vim.notify(("nvim-lint failed: %s"):format(lint_err), vim.log.levels.WARN)
    end
  end,
})
