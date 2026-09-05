-- A technical note on the transparency request: a terminal UI can't
-- blend a fractional opacity per highlight group the way a GUI can --
-- a normal window's background is either "use the terminal's own bg"
-- (fully transparent) or "paint a fixed color" (fully opaque); there's
-- no in-between for a plain split. The one place Neovim *can* do a
-- real graded blend is a floating window, via 'winblend' -- Neovim
-- computes that blend itself, independent of terminal support. So:
-- the buffer stays on the terminal's own transparency (control the
-- actual amount via your terminal, e.g. kitty's `background_opacity`),
-- and the file tree is set up as a floating window with its own
-- winblend value in plugins/filetree.lua, giving it a real, adjustable
-- partial transparency that's distinct from the buffer's.
return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('tokyonight').setup({
      style = 'storm',
      transparent = true,
      styles = {
        floats = 'transparent', -- the floating tree gets its look from winblend, not this
      },
    })
    vim.cmd.colorscheme('tokyonight')
  end,
}
