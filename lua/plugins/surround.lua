return {
	"kunkka19xx/simple-surr",
	config = function()
		require("simple-surr").setup({
			keymaps = {
				surround_selection = "<leader>s", -- Keymap for surrounding selection
				surround_word = "<leader>sw", -- Keymap for surrounding word
				remove_or_change_surround_word = "<leader>sr", -- Keymap for removing/changing surrounding word
				toggle_or_change_surround_selection = "<leader>ts", -- Keymap for removing/changing surrounding selected text
			},
		})
	end,
}
