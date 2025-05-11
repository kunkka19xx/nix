return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "sindrets/diffview.nvim" },
        opts = {
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end
                -- navigation
                map("n", "]h", gs.next_hunk, "Next hunk")
                map("n", "[h", gs.prev_hunk, "Prev hunk")
                -- Actions
                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>hr", gs.stage_hunk, "Reset hunk")
                map("v", "<leader>hs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage hunk")
                map("v", "<leader>hr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Reset hunk")

                map("n", "<leader>hS", gs.stage_hunk, "Stage buffer")
                map("n", "<leader>hR", gs.stage_hunk, "Reset buffer")
                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end, "Blame line")
                map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
                -- diff
                map("n", "<leader>hd", gs.diffthis, "Diff this")
                map("n", "<leader>hD", function()
                    gs.diffthis("~")
                end, "Diff this ~")

                -- text object
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")

                -- Diffview
                vim.keymap.set("n", "<leader>dv", function()
                    if next(require("diffview.lib").views) == nil then
                        vim.cmd("DiffviewOpen")
                    else
                        vim.cmd("DiffviewClose")
                    end
                end, { desc = "Toggle Diffview" })
            end,
        },
    },
}
