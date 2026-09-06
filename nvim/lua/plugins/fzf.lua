vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
}, { load = false })

local p_name = "telescope.nvim" -- on-disk package/directory name, for `packadd`
local m_name = "telescope"      -- require() module name

vim.api.nvim_create_user_command("Telescope", function(opts)
  vim.api.nvim_del_user_command("Telescope")
  vim.cmd("packadd " .. p_name)

  local ok, err = pcall(function() require(m_name).setup({}) end)
  if not ok then
    vim.notify(("%s setup failed: %s"):format(m_name, err), vim.log.levels.ERROR)
  end

  vim.cmd("Telescope " .. opts.args)
end, { nargs = "*" })

