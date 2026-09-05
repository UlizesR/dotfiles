-- Debug adapters are only wired up for C/C++/Rust (codelldb) and
-- Python (debugpy) -- the languages from your list with practical,
-- maintained debugger support in the nvim-dap ecosystem. Bash,
-- Assembly, Lua, Obj-C, GLSL, MSL, and CUDA don't have a realistic
-- DAP story; this stays out rather than wiring up something flaky.
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'jay-babu/mason-nvim-dap.nvim',
  },
  config = function()
    require('mason-nvim-dap').setup({
      ensure_installed = { 'codelldb', 'debugpy' },
      automatic_installation = true,
    })

    local dap, dapui = require('dap'), require('dapui')
    dapui.setup()

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- C / C++ / Rust via codelldb
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
      },
    }
    for _, lang in ipairs({ 'c', 'cpp', 'rust' }) do
      dap.configurations[lang] = {
        {
          name = 'Launch',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }
    end

    -- Python via debugpy
    dap.adapters.python = {
      type = 'executable',
      command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
      args = { '-m', 'debugpy.adapter' },
    }
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
          return 'python3'
        end,
      },
    }
  end,
}
