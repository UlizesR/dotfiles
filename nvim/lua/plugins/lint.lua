return {
  'mfussenegger/nvim-lint',
  event = { 'BufWritePost', 'BufEnter' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      -- ruff replaces the flake8/pylint/isort stack in one fast tool
      python = { 'ruff' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
      -- clangd's built-in clang-tidy (plugins/lsp.lua) already covers
      -- most of this; cppcheck catches a few extra classes of bugs
      c = { 'cppcheck' },
      cpp = { 'cppcheck' },
      objc = { 'cppcheck' },
      -- requires glslangValidator on PATH (Vulkan SDK, or `brew install glslang`)
      glsl = { 'glslang' },
      yaml = { 'yamllint' },
    }

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
      group = vim.api.nvim_create_augroup('NvimLint', { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
