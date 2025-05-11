return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			{
				"fredrikaverpil/neotest-golang",
				version = "*",
				dependencies = { "leoluz/nvim-dap-go" },
			},
			"sidlatau/neotest-dart",
			"lawrence-laz/neotest-zig",
			{
				"rcasia/neotest-java",
				ft = "java",
				dependencies = {
					"mfussenegger/nvim-jdtls",
					"mfussenegger/nvim-dap", -- for the debugger
					"rcarriga/nvim-dap-ui", -- recommended
					"theHamsta/nvim-dap-virtual-text", -- recommended
				},
			},
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-golang")({ recursive_run = true }), -- Registration
					-- require :NeotestJava setup
					["neotest-java"] = {},
					require("neotest-dart")({
						command = "flutter", -- Command being used to run tests. Defaults to `flutter`
						-- Change it to `fvm flutter` if using FVM
						-- change it to `dart` for Dart only tests
						use_lsp = true, -- When set Flutter outline information is used when constructing test name.
						-- Useful when using custom test names with @isTest annotation
						custom_test_method_names = {},
					}),
					-- Registration
					require("neotest-zig")({
						dap = {
							adapter = "lldb",
						},
					}),
				},
			})

			vim.keymap.set("n", "<Leader>tr", ':lua require("neotest").run.run()<CR>', {})
			-- run with debugging, need debug point
			vim.keymap.set("n", "<Leader>tb", ':lua require("neotest").run.run({strategy = "dap"})<CR>', {})
            -- stop running test
			vim.keymap.set("n", "<Leader>ts", ':lua require("neotest").run.stop()<CR>', {})
            -- open dialog 
			vim.keymap.set("n", "<Leader>to", ':lua require("neotest").output.open()<CR>', {})
			-- open and jump in to the dialog
			vim.keymap.set("n", "<Leader>tO", ':lua require("neotest").output.open({ enter = true })<CR>', {})
            -- view test summary
			vim.keymap.set("n", "<Leader>tv", ':lua require("neotest").summary.toggle()<CR>', {})
            -- run all test in file
			vim.keymap.set("n", "<Leader>tp", ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', {})

            -- this is only for test suite in go, I really hate this. 
            -- Will remove after !!!
			local function get_suite_name(file_path)
				local file_content = vim.fn.readfile(file_path)
				for _, line in ipairs(file_content) do
					local suite_match = line:match("^type%s+([%w_]+)Suite%s+struct")
					if suite_match then
						return suite_match
					end
				end
				return nil
			end

			vim.keymap.set("n", "<Leader>tt", function()
				local file_path = vim.fn.expand("%:p")
				local package = vim.fn.fnamemodify(file_path, ":h"):gsub("^%./", "")

				local test_name = vim.fn.input("Enter test method name (e.g., Testxxxx): ")
				if not test_name or test_name == "" then
					vim.notify("Test name cannot be empty.", vim.log.levels.ERROR)
					return
				end

				local suite_name = get_suite_name(file_path)

				if not suite_name then
					vim.notify("Cannot detect suite name in file.", vim.log.levels.ERROR)
					return
				end

				local test_pattern = suite_name .. "Suite/" .. test_name

				vim.cmd("!go test -run " .. test_pattern .. " -v " .. package)
			end, { desc = "Run specific test at cursor" })
		end,
	},
}
