return {
    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<C-y>",
                    clear_suggestion = "<C-]>",
                    accept_word = "<C-j>",
                },
                color = {
                    suggestion_color = "#808080",
                    cterm = 244,
                },
                disable_inline_completion = false,
            })
        end,
    },
}
