-- Pinned to `master`: nvim-treesitter's other branch is a rewrite with
-- a different config API (no `nvim-treesitter.configs.setup`), and
-- picking it up unexpectedly would break this file's syntax entirely.
--
-- A few grammars (latex among them) don't ship a prebuilt binary for
-- every platform and have to be compiled locally, which needs the
-- `tree-sitter` CLI on PATH -- separate from this plugin itself:
--   brew install tree-sitter        (macOS)
--   npm install -g tree-sitter-cli  (any platform with Node)
-- Without it, :TSUpdate/:TSInstall will fail specifically for those
-- grammars while everything else still installs fine.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'c', 'cpp', 'python', 'rust', 'bash', 'asm', 'lua',
        'objc', 'glsl', 'cuda', 'vim', 'toml', 'yaml',
        'latex', 'markdown', 'markdown_inline',
        -- No MSL grammar exists anywhere in the tree-sitter ecosystem;
        -- .metal files fall back to the cpp parser (see options.lua).
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
