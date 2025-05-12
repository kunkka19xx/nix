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
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "oil",
				callback = function()
					local oil_actions = require("oil.actions")

					local map = function(lhs, rhs, opts)
						opts = vim.tbl_extend("force", { buffer = true, noremap = true, silent = true }, opts or {})
						vim.keymap.set("n", lhs, rhs, opts)
					end

					map("g?", oil_actions.show_help.callback)
					map("<CR>", oil_actions.select.callback)
					map("<C-t>", function()
						oil_actions.select.callback({ tab = true })
					end)
					map("<C-p>", function()
						oil_actions.preview.callback({ vertical = true, split = "rightbelow" })
					end)
					map("<C-c>", oil_actions.close.callback)
					map("R", oil_actions.refresh.callback)
					map("-", oil_actions.parent.callback)
					map("_", oil_actions.open_cwd.callback)
					map("`", oil_actions.cd.callback)
					map("~", function()
						oil_actions.cd.callback({ scope = "tab" })
					end)
					map("gs", oil_actions.change_sort.callback)
					map("gx", oil_actions.open_external.callback)
					map("H", oil_actions.toggle_hidden.callback)
					map("g\\", oil_actions.toggle_trash.callback)
				end,
			}),
			use_default_keymaps = false,
		})

		vim.keymap.set("n", "<leader>vv", require("oil").open, { desc = "Open parent directory" })
		vim.keymap.set("n", "<leader>vf", require("oil").open_float, { desc = "Oil float" })

		vim.keymap.set("n", "<leader>vi", function()
			local oil = require("oil")
			local entry = oil.get_cursor_entry()
			local dir = oil.get_current_dir()

			if entry and dir then
				local full_path = vim.fn.fnamemodify(dir .. entry.name, ":p")

				local stat = vim.loop.fs_stat(full_path)

				if stat then
					vim.notify(
						vim.inspect({
							name = entry.name,
							type = entry.type,
							full_path = full_path,
							size = stat.size,
							mode = stat.mode,
							mtime = os.date("%c", stat.mtime.sec),
						}),
						vim.log.levels.INFO,
						{ title = "Oil Entry Info" }
					)
				else
					vim.notify("Failed to stat file: " .. full_path, vim.log.levels.WARN)
				end
			else
				vim.notify("No entry under cursor", vim.log.levels.WARN)
			end
		end, { desc = "Show full file info from Oil" })
	end,
}
