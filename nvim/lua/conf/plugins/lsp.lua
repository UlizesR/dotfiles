return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/nvim-cmp",
  },

  config = function()
    -- ── LSP keymaps (attached per-buffer) ──────────────────────────────────────
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        local o = { buffer = event.buf }
        vim.keymap.set("n", "K",    "<cmd>lua vim.lsp.buf.hover()<cr>",           vim.tbl_extend("force", o, { desc = "Show docs for symbol under cursor" }))
        vim.keymap.set("n", "gd",   "<cmd>lua vim.lsp.buf.definition()<cr>",      vim.tbl_extend("force", o, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD",   "<cmd>lua vim.lsp.buf.declaration()<cr>",     vim.tbl_extend("force", o, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gi",   "<cmd>lua vim.lsp.buf.implementation()<cr>",  vim.tbl_extend("force", o, { desc = "Go to implementation" }))
        vim.keymap.set("n", "go",   "<cmd>lua vim.lsp.buf.type_definition()<cr>", vim.tbl_extend("force", o, { desc = "Go to type definition" }))
        vim.keymap.set("n", "gr",   "<cmd>lua vim.lsp.buf.references()<cr>",      vim.tbl_extend("force", o, { desc = "List all references to symbol" }))
        vim.keymap.set("n", "gs",   "<cmd>lua vim.lsp.buf.signature_help()<cr>",  vim.tbl_extend("force", o, { desc = "Show function signature help" }))
        vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>",          vim.tbl_extend("force", o, { desc = "Rename symbol under cursor" }))
        vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>",     vim.tbl_extend("force", o, { desc = "Show available code actions" }))
      end,
    })

    -- ── Mason ──────────────────────────────────────────────────────────────────
    require("mason").setup()

    require("mason-lspconfig").setup({
      ensure_installed = { "clangd", "pyright", "rust_analyzer", "texlab" },
      handlers = {
        -- Default: auto-configure everything
        function(server_name)
          require("lspconfig")[server_name].setup({})
        end,

        -- LaTeX / BibTeX
        texlab = function()
          require("lspconfig").texlab.setup({
            settings = {
              texlab = {
                build = {
                  executable = "latexmk",
                  args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                  onSave = false,
                  forwardSearchAfter = false,
                },
                chktex = {
                  onOpenAndSave = true,
                },
              },
            },
          })
        end,

        -- C/C++/ObjC: extra flags
        clangd = function()
          require("lspconfig").clangd.setup({
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=never",
              "--completion-style=detailed",
              "--function-arg-placeholders",
            },
            filetypes = { "c", "cpp", "objc", "objcpp" },
          })
        end,
      },
    })

    -- ── Completion ─────────────────────────────────────────────────────────────
    local cmp = require("cmp")

    local kind_icons = {
      Text = "", Method = "m", Function = "", Constructor = "",
      Field = "", Variable = "", Class = "", Interface = "",
      Module = "", Property = "", Unit = "", Value = "",
      Enum = "", Keyword = "", Snippet = "", Color = "",
      File = "", Reference = "", Folder = "", EnumMember = "",
      Constant = "", Struct = "", Event = "", Operator = "",
      TypeParameter = "",
    }

    cmp.setup({
      sources = { { name = "nvim_lsp" } },

      mapping = cmp.mapping.preset.insert({
        ["<C-k>"]     = cmp.mapping.select_prev_item(),
        ["<C-j>"]     = cmp.mapping.select_next_item(),
        ["<C-b>"]     = cmp.mapping.scroll_docs(-1),
        ["<C-f>"]     = cmp.mapping.scroll_docs(1),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"]     = cmp.mapping.abort(),
        ["<CR>"]      = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item() else fallback() end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item() else fallback() end
        end, { "i", "s" }),
      }),

      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            buffer   = "[Buffer]",
            path     = "[Path]",
          })[entry.source.name]
          return vim_item
        end,
      },
    })
  end,
}

