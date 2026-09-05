-- Neovim 0.11+ moved LSP configuration into core: instead of calling
-- require('lspconfig')[name].setup({...}), you register config with
-- vim.lsp.config(name, {...}) and turn it on with vim.lsp.enable(name).
-- nvim-lspconfig's job now is just to ship the default configs for
-- hundreds of servers (registered automatically when the plugin
-- loads) -- we only override the handful of settings we care about.
--
-- LSP coverage by requested language:
--   C/C++/Obj-C/CUDA -> clangd (one server, multiple filetypes)
--   Python            -> pyright
--   Rust              -> rust_analyzer (routed through clippy)
--   Bash              -> bashls
--   Assembly          -> asm_lsp (coverage is thin industry-wide)
--   Lua               -> lua_ls (pointed at Neovim's own runtime)
--   GLSL              -> glsl_analyzer
--   Vim(script)       -> vimls
--   TOML              -> taplo
--   YAML              -> yamlls
--   LaTeX             -> texlab
--   Markdown          -> marksman
--   MSL               -> no LSP exists; not included (see options.lua)
return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    require('mason').setup()

    local servers = {
      'clangd', 'pyright', 'rust_analyzer', 'bashls', 'lua_ls',
      'glsl_analyzer', 'asm_lsp', 'vimls', 'taplo', 'yamlls',
      'texlab', 'marksman',
    }

    local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    local capabilities = ok and cmp_nvim_lsp.default_capabilities()
      or vim.lsp.protocol.make_client_capabilities()

    -- Applies to every server unless a per-server vim.lsp.config()
    -- call below overrides it.
    vim.lsp.config('*', { capabilities = capabilities })

    vim.lsp.config('clangd', {
      filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=never',
      },
    })

    vim.lsp.config('rust_analyzer', {
      settings = {
        ['rust-analyzer'] = { check = { command = 'clippy' } },
      },
    })

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          diagnostics = { globals = { 'vim' } },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })

    -- automatic_enable installs each server via Mason, then calls
    -- vim.lsp.enable() only once the install actually finishes --
    -- this is what fixes the "server not found" race on a first run.
    require('mason-lspconfig').setup({
      ensure_installed = servers,
      automatic_enable = true,
    })
  end,
}
