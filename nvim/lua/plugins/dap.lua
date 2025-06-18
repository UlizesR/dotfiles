return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
        "jay-babu/mason-nvim-dap.nvim",
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",    -- optional, if you use neotest’s dap integration
    },
    config = function()
        local dap   = require("dap")
        local dapui = require("dapui")

        -- 1) Install and configure all adapters via mason
        require("mason-nvim-dap").setup({
            ensure_installed = { "cppdbg" },       -- make sure cpptools adapter is installed
            automatic_installation = true,         -- install configured adapters automatically
            handlers = {
                -- fallback to default_setup for all adapters
                function(config)
                    require("mason-nvim-dap").default_setup(config)
                end,
            },
        })

        -- 2) Configure the DAP UI
        dapui.setup()

        -- 3) Attach keymaps whenever an LSP (or dap) attaches to a buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserDapConfig", { clear = true }),
                callback = function(ev)
                local buf = ev.buf
                local function map(lhs, fn, desc)
                    vim.keymap.set("n", lhs, fn, { buffer = buf, desc = desc })
                end

                map("<leader>dt", dap.toggle_breakpoint, "DAP: Toggle Breakpoint")
                map("<leader>dc", dap.continue,         "DAP: Continue")
                map("<leader>dr", dap.repl.open,        "DAP: Open REPL")
                map("<leader>dk", dap.terminate,        "DAP: Terminate")
                map("<leader>dso", dap.step_over,       "DAP: Step Over")
                map("<leader>dsi", dap.step_into,       "DAP: Step Into")
                map("<leader>dsu", dap.step_out,        "DAP: Step Out")
                map("<leader>dl", dap.run_last,         "DAP: Run Last")
                map("<leader>duu", dapui.open,          "DAP: Open UI")
                map("<leader>duc", dapui.close,         "DAP: Close UI")
            end,
        })

        -- 4) Define your C++ debug configurations
        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "cppdbg",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopAtEntry = true,
            },
            {
                name = "Attach to gdbserver :1234",
                type = "cppdbg",
                request = "launch",
                MIMode = "gdb",
                miDebuggerServerAddress = "localhost:1234",
                miDebuggerPath = "/usr/bin/gdb",
                cwd = "${workspaceFolder}",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
            },
        }
        end,
    },
}
