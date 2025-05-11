return {
    "stevearc/oil.nvim",
    -- Optional dependencies
    dependencies = {
        {
            "echasnovski/mini.icons",
            opts = {
                style = "glyphs",
            },
        },
    },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function()
        require("oil").setup({
            float = {
                -- Padding around the floating window
                padding = 2,
                max_width = 90,
                max_height = 0,
                -- border = "rounded",
                win_options = {
                    winblend = 0,
                },
            },
            keymaps = {
                ["g?"] = { "actions.show_help", mode = "n" },
                ["<CR>"] = "actions.select",
                ["<C-S>"] = { "actions.select", opts = { vertical = true } },
                ["<C-H>"] = { "actions.select", opts = { horizontal = true } },
                ["<C-t>"] = { "actions.select", opts = { tab = true } },
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = { "actions.close", mode = "n" },
                ["<C-l>"] = "actions.refresh",
                ["-"] = { "actions.parent", mode = "n" },
                ["_"] = { "actions.open_cwd", mode = "n" },
                ["`"] = { "actions.cd", mode = "n" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gx"] = "actions.open_external",
                ["g."] = { "actions.toggle_hidden", mode = "n" },
                ["g\\"] = { "actions.toggle_trash", mode = "n" },
            },
        })

        vim.keymap.set("n", "<leader>vv", require("oil").open, { desc = "Open parent directory" })
        vim.keymap.set("n", "<leader>vf", require("oil").open_float, { desc = "Oil float" })
    end,
}
