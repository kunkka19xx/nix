return {
    {
        "folke/tokyonight.nvim",
        name = "tokyonight",
        priority = 999,
        config = function()
            -- Set default theme
            local themes = {
                "tokyonight",
                "catppuccin",
                "rose-pine",
                "none",
            }

            local current_theme_index = 1
            -- Set default theme (first theme)
            vim.cmd.colorscheme(themes[current_theme_index])

            -- Key mapping to switch themes (e.g., <leader>nt)
            vim.keymap.set("n", "<leader>nt", function()
                current_theme_index = current_theme_index + 1
                if current_theme_index > #themes then
                    current_theme_index = 1
                end
                local theme = themes[current_theme_index]
                if theme == "none" then
                    vim.cmd("hi clear")
                    print("Theme disabled.")
                else
                    vim.cmd.colorscheme(theme)
                    print("Changed nvim theme to: " .. theme)
                end
            end, { noremap = true, silent = true })
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 800,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
    },
}
