local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("go", {
	s("ifer", {
		t({
			"if err != nil {",
			'\tlog.Error("something")',
			"}",
		}),
	}),
	s("iferr", {
		t({
			"if err != nil {",
			'\tlog.Error("something")',
			"\treturn err",
			"}",
		}),
	}),
})
