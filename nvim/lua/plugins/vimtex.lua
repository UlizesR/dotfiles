return {
    "lervag/vimtex",
    init = function()
        vim.g['vimtex_view_method'] = 'zathura_simple' -- Use zathura_simple for compatibility with Wayland
        vim.g['vimtex_quickfix_mode'] = 0              -- Suppress error reporting on save and build
        vim.g['vimtex_mappings_enabled'] = 0           -- Disable default mappings
        vim.g['vimtex_indent_enabled'] = 0             -- Disable auto indenting
        vim.g['tex_flavor'] = 'latex'                  -- Set LaTeX as the TeX flavor
        vim.g['tex_indent_items'] = 0                  -- Disable indenting of items in enumerate
        vim.g['tex_indent_brace'] = 0                  -- Disable brace indenting
        vim.g['vimtex_context_pdf_viewer'] = 'zathura' -- Use zathura as the default PDF viewer
        vim.g['vimtex_log_ignore'] = {                 -- Suppress specific LaTeX warnings
            'Underfull',
            'Overfull',
            'specifier changed to',
            'Token not allowed in a PDF string',
        }
        vim.keymap.set('n', '<leader>b', ':VimtexCompile<CR>', {desc = "Build LaTeX document"})
        vim.keymap.set('n',  '<leader>vp', ':VimtexView<CR>', {desc = "View PDF document"})
    end,
}

