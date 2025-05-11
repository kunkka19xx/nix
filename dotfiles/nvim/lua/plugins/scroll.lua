return {
	"karb94/neoscroll.nvim",
	opts = {},
	config = function()
		local neoscroll = require("neoscroll")

		require("neoscroll").setup({
			hide_cursor = false, -- Hide cursor while scrolling
			stop_eof = true, -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
			cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
			duration_multiplier = 0.8, -- Global duration multiplier
			easing = "linear", -- Default easing function
			pre_hook = nil, -- Function to run before the scrolling animation starts
			post_hook = nil, -- Function to run after the scrolling animation ends
			performance_mode = false, -- Disable "Performance Mode" on all buffers.
			ignored_events = { -- Events ignored while scrolling
				"WinScrolled",
				"CursorMoved",
			},
		})
		local keymap = {
			["<C-e>"] = function()
				neoscroll.ctrl_u({ duration = 300 })
			end,
			["<C-d>"] = function()
				neoscroll.ctrl_d({ duration = 300 })
			end,
			["<C-b>"] = function()
				neoscroll.ctrl_b({ duration = 450 })
			end,
			["<C-f>"] = function()
				neoscroll.ctrl_f({ duration = 450 })
			end,
			["<C-y>"] = function()
				neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 })
			end,
			["<C-u>"] = function()
				neoscroll.scroll(0.1, { move_cursor = false, duration = 100 })
			end,
			["zt"] = function()
				neoscroll.zt({ half_win_duration = 300 })
			end,
			["zz"] = function()
				neoscroll.zz({ half_win_duration = 300 })
			end,
			["zb"] = function()
				neoscroll.zb({ half_win_duration = 300 })
			end,
		}
		local modes = { "n", "v", "x" }
		for key, func in pairs(keymap) do
			vim.keymap.set(modes, key, func)
		end
	end,
}
