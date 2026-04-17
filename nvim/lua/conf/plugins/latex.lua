return {
  "lervag/vimtex",
  lazy = false,

  init = function()
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_mode = 0
  end,

  config = function()
    local map = vim.keymap.set

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "plaintex", "bib" },
      callback = function(event)
        local o = { buffer = event.buf }

        map("n", "<leader>ll", "<cmd>VimtexCompile<CR>", vim.tbl_extend("force", o, { desc = "LaTeX: compile" }))
        map("n", "<leader>lv", "<cmd>VimtexView<CR>", vim.tbl_extend("force", o, { desc = "LaTeX: view PDF" }))
        map("n", "<leader>le", "<cmd>VimtexErrors<CR>", vim.tbl_extend("force", o, { desc = "LaTeX: show errors" }))
        map("n", "<leader>lc", "<cmd>VimtexClean<CR>", vim.tbl_extend("force", o, { desc = "LaTeX: clean aux files" }))
        map("n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", vim.tbl_extend("force", o, { desc = "LaTeX: toggle TOC" }))
      end,
    })
  end,
}
