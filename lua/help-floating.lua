vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	callback = function()
        local crbuf = vim.api.nvim_get_current_buf()
        vim.cmd("wincmd c")
		-- vim.cmd("wincmd L")
		vim.api.nvim_open_win(crbuf, true, {
			relative = "editor",
			width = math.floor(vim.o.columns * 0.8),
			height = math.floor(vim.o.lines * 0.8),
			col = math.floor(vim.o.columns * 0.1),
			row = math.floor(vim.o.lines * 0.1),
			border = "rounded",
		})
	end,
})
