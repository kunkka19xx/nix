local is_mac = vim.fn.has("mac") == 1
return {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
        "ibhagwan/fzf-lua",
        "MunifTanjim/nui.nvim",
        -- "nvim-tree/nvim-tree.lua",
        "stevearc/oil.nvim",
    },
    config = function()
        require("xcodebuild").setup({
            show_build_progress_bar = true,
            logs = {
                auto_open_on_success_tests = false,
                auto_open_on_failed_tests = false,
                auto_open_on_success_build = false,
                auto_open_on_failed_build = true,
                auto_focus = false,
                auto_close_on_app_launch = true,
            },
            code_coverage = {
                enabled = true,
            },
        })

        vim.keymap.set("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Xcodebuild Logs" })
        vim.keymap.set("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
        vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })
        vim.keymap.set("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
        vim.keymap.set("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run This Test Class" })
        vim.keymap.set("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device/Simulator" })
        vim.keymap.set("n", "<leader>xp", "<cmd>XcodebuildSelectProject<cr>", { desc = "Select Project/Workspace" })
    end,
}
