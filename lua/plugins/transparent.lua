return {
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			enable = true,
			extra_groups = {
				"Normal",
				"NormalNC",
				"TelescopeBorder",
				-- "NvimTreeNormal",
				"LualineNormal",
				"FzfLuaBorder",
				"FzfLuaNormal",
				"FzfLuaTitle",
				"FzfLuaPreviewBorder",
				"FzfLuaPreviewNormal",
				"FzfLuaPreviewTitle",
			},
		})
		-- require("transparent").clear_prefix("NeoTree")
		require("transparent").clear_prefix("lualine")
		-- depends on pc, these settings are needed
		vim.cmd("highlight Normal guibg=NONE")
		vim.cmd("highlight Lualine guibg=NONE")
		vim.cmd("highlight Lualine guifg=NONE")
		vim.cmd("highlight NormalNC guibg=NONE")
		vim.cmd("highlight CursorLine guibg=NONE")
	end,
}
