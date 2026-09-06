vim.api.nvim_create_user_command("PackUpdate", function(opts)
  local names = #opts.fargs > 0 and opts.fargs or nil
  vim.pack.update(names)
end, {
  nargs = "*",
  complete = function()
    return vim.tbl_map(function(p) return p.spec.name end, vim.pack.get())
  end,
  desc = "Update all (or named) vim.pack plugins",
})

vim.api.nvim_create_user_command("PackDel", function(opts)
  if #opts.fargs == 0 then
    vim.notify("PackDel: give at least one plugin name (see :PackDel <Tab>)", vim.log.levels.WARN)
    return
  end
  vim.pack.del(opts.fargs)
end, {
  nargs = "+",
  complete = function()
    return vim.tbl_map(function(p) return p.spec.name end, vim.pack.get())
  end,
  desc = "Delete one or more vim.pack plugins from disk",
})


vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("PackLifecycle", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    vim.notify(("[vim.pack] %s: %s"):format(kind, name), vim.log.levels.INFO)
  end,
})

