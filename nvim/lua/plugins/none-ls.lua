return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				cpp = { "clang_format" },
				c = { "clang_format" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				markdown = { "vale" },
				text = { "vale" },
			}
			
			-- Auto-lint on text change and buffer enter
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
