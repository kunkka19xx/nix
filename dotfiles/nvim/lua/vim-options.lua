vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set cursorline")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "white" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#ead84e" })
vim.api.nvim_set_option("clipboard", "unnamed")
vim.opt.hlsearch = true
vim.opt.incsearch = true
-- move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- paste over highlight word
vim.keymap.set("x", "<leader>p", '"_dP')
vim.opt.colorcolumn = "94"
-- fk llm-ls
local notify_original = vim.notify
vim.notify = function(msg, ...)
	if
		msg
		and (
			msg:match("position_encoding param is required")
			or msg:match("Defaulting to position encoding of the first client")
			or msg:match("multiple different client offset_encodings")
		)
	then
		return
	end
	return notify_original(msg, ...)
end
vim.opt.swapfile = false
