return {
    {
        "nvim-telescope/telescope.nvim",
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim', build = 'make'
            }
        },
        config = function()
            local tsb = require('telescope.builtin')
            local ts = require('telescope')

            ts.setup({
                extensions = {
                    fzf = {}
                }
            })
            ts.load_extension('fzf')

            vim.keymap.set('n', '<leader>ff', tsb.find_files, { desc = "Find Files in current directory" })
            vim.keymap.set('n', '<leader>fh', tsb.help_tags, { desc = 'Telescope help tags' })
            vim.keymap.set('n', '<leader>en', function()
                tsb.find_files {
                    cwd = vim.fn.stdpath('config')
                }
            end, { desc = "Navigate to config" })
            vim.keymap.set("n", "<space>ep", function()
                require('telescope.builtin').find_files {
                    cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
                }
            end, { desc = "Navigate to lazy" })

            vim.keymap.set('n', '<leader>vgc', tsb.git_commits, { desc = "Git commits" })
            vim.keymap.set('n', '<leader>vgb', tsb.git_branches, { desc = "Git branches" })
            vim.keymap.set('n', '<leader>vgs', tsb.git_status, { desc = "Git status" })

        end,
    }
}