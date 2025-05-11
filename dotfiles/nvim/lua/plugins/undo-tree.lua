return {
	"mbbill/undotree",
	config = function()
		vim.keymap.set("n", "<leader>ut", vim.cmd.UndotreeToggle)
		vim.keymap.set("n", "<leader>uf", vim.cmd.UndotreeFocus)
	end,
}
