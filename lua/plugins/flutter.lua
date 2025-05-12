return {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
        require("flutter-tools").setup({}) -- use defaults
        -- Set indentation to 2 spaces for Dart/Flutter files
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "dart",
            callback = function()
                vim.opt_local.tabstop = 2
                vim.opt_local.shiftwidth = 2
                vim.opt_local.softtabstop = 2
                vim.opt_local.expandtab = true
            end,
        })
    end,
}
