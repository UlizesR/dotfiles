return {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {},
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (trouble)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (trouble)" },
        { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (trouble)" },
        { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (trouble)" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list (trouble)" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list (trouble)" },
        {
            "[q",
            function()
                if require("trouble").is_open() then
                    require("trouble").prev({ skip_groups = true, jump = true }, {})
                else
                    local ok, err = pcall(vim.cmd.cprev)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Previous Trouble/Quickfix item",
        },
        {
            "]q",
            function()
                if require("trouble").is_open() then
                    require("trouble").next({ skip_groups = true, jump = true }, {})
                else
                    local ok, err = pcall(vim.cmd.cnext)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Next Trouble/Quickfix item",
        },
    },
} 