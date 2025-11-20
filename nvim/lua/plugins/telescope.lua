return {
    {
        "nvim-telescope/telescope.nvim",
        tag = '0.1.8',
        cmd = "Telescope",
        keys = {
            { "<leader>ff", desc = "Find files" },
            { "<leader>fg", desc = "Live grep" },
            { "<leader>fb", desc = "Find buffers" },
            { "<leader>fh", desc = "Help tags" },
            { "<leader>en", desc = "Navigate to config" },
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim', build = 'make'
            },
            'nvim-telescope/telescope-ui-select.nvim',
        },
        config = function()
            local tsb = require('telescope.builtin')
            local ts = require('telescope')

            ts.setup({
                defaults = {
                    file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },
                    layout_config = {
                        horizontal = { preview_width = 0.6 }
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({})
                    },
                }
            })
            ts.load_extension('fzf')
            ts.load_extension('ui-select')

            vim.keymap.set('n', '<leader>ff', tsb.find_files, { desc = "Find Files in current directory" })
            vim.keymap.set('n', '<leader>fg', tsb.live_grep, { desc = "Live grep in project" })
            vim.keymap.set('n', '<leader>fb', tsb.buffers, { desc = "Find buffers" })
            vim.keymap.set('n', '<leader>fh', tsb.help_tags, { desc = 'Telescope help tags' })
            vim.keymap.set('n', '<leader>en', function()
                tsb.find_files {
                    cwd = vim.fn.stdpath('config')
                }
            end, { desc = "Navigate to config" })

        end,
    }
}