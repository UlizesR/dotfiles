return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "jay-babu/mason-nvim-dap.nvim",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<leader>dt", desc = "Toggle Breakpoint" },
            { "<leader>dc", desc = "Continue" },
            { "<leader>dr", desc = "Open REPL" },
            { "<leader>dk", desc = "Terminate" },
            { "<leader>dso", desc = "Step Over" },
            { "<leader>dsi", desc = "Step Into" },
            { "<leader>dsu", desc = "Step Out" },
            { "<leader>du", desc = "Toggle DAP UI" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Install and configure adapters via mason
            require("mason-nvim-dap").setup({
                ensure_installed = { "cppdbg", "python" },
                automatic_installation = true,
                handlers = {
                    function(config)
                        require("mason-nvim-dap").default_setup(config)
                    end,
                },
            })

            -- Configure DAP UI
            dapui.setup()

            -- Auto-open/close UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- Keymaps
            vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
            vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
            vim.keymap.set("n", "<leader>dk", dap.terminate, { desc = "DAP: Terminate" })
            vim.keymap.set("n", "<leader>dso", dap.step_over, { desc = "DAP: Step Over" })
            vim.keymap.set("n", "<leader>dsi", dap.step_into, { desc = "DAP: Step Into" })
            vim.keymap.set("n", "<leader>dsu", dap.step_out, { desc = "DAP: Step Out" })
            vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })

            -- C++ debug configurations
            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "cppdbg",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtEntry = false,
                },
            }
            dap.configurations.c = dap.configurations.cpp
        end,
    },
}

