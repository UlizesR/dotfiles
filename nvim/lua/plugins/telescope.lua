return {
{
    'nvim-telescope/telescope-ui-select.nvim',
},
{
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim', 'jonarrien/telescope-cmdline.nvim' },
    config = function()
        local tele = require('telescope')
        tele.setup({
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown{}
                },
                cmdline = {
                    picker = {
                        layout_config = {width  = 120, height = 25,}
                    },
                    mappings = {
                        complete = '<Tab>',
                        run_selection = '<C-CR>',
                        run_input = '<CR>',
                    },
                },
            }
        })
        require('telescope').load_extension("ui-select")
        local builtin = require('telescope.builtin')

        -- Keybindings for existing Telescope commands
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = "Find Files"})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = "Live Grep"})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {desc = "Buffers"})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = "Help Tags"})
        vim.keymap.set('n', ':', ':Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })

        -- Function to show all keymaps using Telescope
        local function show_keymaps()
            local opts = {
                layout_strategy = 'vertical',
                layout_config = { width = 0.75 },
            }
            require('telescope.builtin').keymaps(opts)
        end

        -- Command to show keymaps
        vim.api.nvim_create_user_command('ShowKeymaps', show_keymaps, {})

        -- Optional: Bind the command to a key combination with a description
        vim.keymap.set('n', '<leader>sk', ':ShowKeymaps<CR>', { noremap = true, silent = true, desc = "Show all keymaps" })

    end,
},
}
