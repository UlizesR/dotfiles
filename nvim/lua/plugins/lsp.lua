return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-omni",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-cmdline",
            "echasnovski/mini.nvim",
            "j-hui/fidget.nvim",  -- Adds LSP progress information
        },

        config = function()
            -- Setup fidget.nvim for LSP progress
            require("fidget").setup()

            -- Setup nvim-cmp
            local cmp = require("cmp")
            local cmp_nvim_lsp = require("cmp_nvim_lsp")
            local luasnip = require("luasnip")
            
            -- Load required cmp extensions
            require("cmp_path")
            require("cmp_buffer")
            require("cmp_omni")
            require("cmp_cmdline")

            local MiniIcons = require("mini.icons")

            -- Customize diagnostic signs
            local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- Customize diagnostics
            vim.diagnostic.config({
                virtual_text = {
                    prefix = '●',
                    source = "if_many",
                },
                float = {
                    source = "always",
                    border = "rounded",
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- Customize LSP handlers
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover,
                { border = "rounded" }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help,
                { border = "rounded" }
            )

            local capabilities = cmp_nvim_lsp.default_capabilities()

            -- Create format augroup once (outside on_attach for efficiency)
            local format_augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

            local on_attach = function(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Mappings.
                local bufopts = { noremap=true, silent=true, buffer=bufnr }
                
                -- LSP Navigation
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
                
                -- Workspace management
                vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
                vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set('n', '<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, bufopts)
                
                -- Code actions and modifications
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
                vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
                
                -- Diagnostic keymaps
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
                vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
                vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, bufopts)

                -- Format on save if the client supports it
                if client.server_capabilities.documentFormattingProvider then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = format_augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ async = false })
                        end,
                    })
                end
            end

            -- Setup nvim-cmp
            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert {
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<CR>"] = cmp.mapping.confirm { 
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true 
                    },
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                },
                sources = cmp.config.sources({
                    { name = "copilot", priority = 1100 },
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip", priority = 750 },
                    { name = "path", priority = 500 },
                    { name = "buffer", priority = 250, keyword_length = 2 },
                }),
                sorting = {
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                completion = {
                    keyword_length = 1,
                    completeopt = "menu,noselect",
                },
                view = {
                    entries = "custom",
                },
                formatting = {
                    format = function(entry, vim_item)
                        local icon, hl = MiniIcons.get("lsp", vim_item.kind)
                        vim_item.kind = icon .. " " .. vim_item.kind
                        vim_item.kind_hl_group = hl
                        
                        -- Add source name to completion menu
                        vim_item.menu = ({
                            copilot = "[Copilot]",
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                        })[entry.source.name]
                        
                        return vim_item
                    end,
                },
            }

            -- Command line completion
            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
                matching = { disallow_symbol_nonprefix_matching = false },
            })

            -- Setup highlighting
            vim.cmd([[
                highlight! link CmpItemMenu Comment
                " gray
                highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
                " blue
                highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
                highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
                " light blue
                highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
                highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
                highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
                " pink
                highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
                highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
                " front
                highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
                highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
                highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
            ]])

            -- LSP Server Configurations
            local servers = {
                -- C/C++ (Note: paths below are configured for macOS with Homebrew)
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=never",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=Google",
                    },
                    init_options = {
                        compilationDatabaseDirectory = "build",
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                    settings = {
                        clangd = {
                            arguments = {
                                "--query-driver=/opt/homebrew/opt/llvm/bin/clang",
                                "-I/opt/homebrew/include",
                                "-I/opt/homebrew/opt/llvm/include",
                                "-I/usr/local/include",
                                "-I/usr/include",
                                "-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include",
                                "-L/opt/homebrew/lib",
                                "-L/opt/homebrew/opt/llvm/lib",
                                "-L/usr/local/lib",
                                "-L/usr/lib",
                                "-L/opt/homebrew/bin",
                                "-L/usr/local/bin",
                                "-L/usr/bin",
                                "-L/opt/homebrew/opt/llvm/bin",
                            },
                        },
                    },
                },
                -- Lua (needed for Neovim config)
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim' },
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = {
                                enable = false,
                            },
                        },
                    },
                },
                -- Python
                pyright = {},
            }

            -- Setup all servers using modern vim.lsp.config API (Neovim 0.11+)
            for server, config in pairs(servers) do
                config.capabilities = capabilities
                config.on_attach = on_attach
                config.flags = { debounce_text_changes = 150 }
                
                -- Use vim.lsp.config instead of lspconfig
                vim.lsp.config(server, config)
            end
        end,
    }
}