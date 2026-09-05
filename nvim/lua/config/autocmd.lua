-------------------------------------------------------------------
-- Auto-create missing directories on save
-------------------------------------------------------------------
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('AutoCreateDir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    local dir = vim.fn.fnamemodify(file, ':p:h')

    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-------------------------------------------------------------------
-- Auto-reload config on save
--    Only triggers for *.lua files inside your config dir (real-path
--    matched, so it still works through a dotfiles symlink).
--    Reloads only the module that was saved, not the whole config, so
--    unrelated plugin setup() calls -- e.g. nvim-tree -- don't get
--    re-run and reset UI state like an open file tree.
-------------------------------------------------------------------
local config_dir_real = vim.uv.fs_realpath(vim.fn.stdpath('config'))

vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('NvimConfigAutoReload', { clear = true }),
  pattern = '*.lua',
  callback = function(event)
    local saved_real = vim.uv.fs_realpath(event.match)
    if not saved_real or not config_dir_real then
      return
    end
    if not vim.startswith(saved_real, config_dir_real .. '/') then
      return
    end

    vim.schedule(function()
      local lua_marker = '/lua/'
      local idx = saved_real:find(lua_marker, 1, true)

      if not idx then
        -- Saved file isn't under lua/ (e.g. init.lua itself) -- full
        -- re-source is the only option here.
        local ok, err = pcall(vim.cmd.source, config_dir_real .. '/init.lua')
        if ok then
          vim.notify('Config reloaded', vim.log.levels.INFO)
        else
          vim.notify('Reload failed: ' .. tostring(err), vim.log.levels.ERROR)
        end
        return
      end

      local mod_name = saved_real
        :sub(idx + #lua_marker)
        :gsub('%.lua$', '')
        :gsub('/', '.')
        :gsub('%.init$', '')

      package.loaded[mod_name] = nil
      local ok, err = pcall(require, mod_name)
      if ok then
        vim.notify('Reloaded ' .. mod_name, vim.log.levels.INFO)
      else
        vim.notify('Reload failed for ' .. mod_name .. ':\n' .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end,
})
