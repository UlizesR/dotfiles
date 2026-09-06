vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
}, { load = false })

local ok, dap = pcall(require, "dap")
if not ok then
  vim.notify(("nvim-dap failed to load: %s"):format(dap), vim.log.levels.ERROR)
  return
end

-- Open dap-ui automatically when a debug session starts, close it when the
-- session ends -- this is the standard nvim-dap-ui wiring, not something
-- dap-ui does on its own.
local ui_ok, dapui = pcall(require, "dapui")
if ui_ok then
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
else
  vim.notify(("nvim-dap-ui failed to load: %s"):format(dapui), vim.log.levels.ERROR)
end

dap.adapters.lldb = {
  type = "executable",
  command = "lldb-dap",
  name = "lldb",
}

-- debugpy -- `pip install debugpy`
dap.adapters.python = {
  type = "executable",
  command = "python3",
  args = { "-m", "debugpy.adapter" },
}

local lldb_config = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}

dap.configurations.c = lldb_config
dap.configurations.cpp = lldb_config
dap.configurations.objc = lldb_config
dap.configurations.objcpp = lldb_config
dap.configurations.rust = lldb_config
dap.configurations.asm = lldb_config

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      return "python3"
    end,
  },
}
