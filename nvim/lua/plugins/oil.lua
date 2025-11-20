return {
	{
		"stevearc/oil.nvim",
		dependencies = { "echasnovski/mini.icons" },
		config = function()
			require("oil").setup({
				columns = { "icon" },
				keymaps = {
					["<C-h>"] = false,
					["<C-l>"] = false,
					["<C-k>"] = false,
					["<C-j>"] = false,
					["<M-h>"] = "actions.select_split",
					["a"] = "actions.create",      -- Create new file/directory
					["d"] = "actions.remove",      -- Delete file/directory
					["r"] = "actions.rename",       -- Rename file/directory
					["y"] = "actions.copy",        -- Copy file/directory
					["x"] = "actions.cut",          -- Cut file/directory
					["p"] = "actions.paste",        -- Paste file/directory
				},
				view_options = { show_hidden = true },
			})

			-- Open parent directory in current window
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end,
	},
}