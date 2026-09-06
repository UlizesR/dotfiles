-- ==========================================================================
-- GITSIGNS -- event-triggered lazy loading
-- ==========================================================================
vim.pack.add({ { src = "https://github.com/lewis6991/gitsigns.nvim" } }, { load = false })

local p_name = "gitsigns.nvim" -- on-disk package/directory name, for `packadd`
local m_name = "gitsigns"      -- require() module name

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("GitsignsLazyLoad", { clear = true }),
  once = true, -- destroys itself the first time it triggers, so gitsigns only loads once
  callback = function()
    vim.cmd("packadd " .. p_name)
    -- Deferred so setup() doesn't block the redraw of the event that triggered it.
    vim.schedule(function()
      local ok, err = pcall(function() require(m_name).setup({}) end)
      if not ok then
        vim.notify(("%s setup failed: %s"):format(m_name, err), vim.log.levels.ERROR)
      end
    end)
  end,
})

