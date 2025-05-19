local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("go", {
	s("ifer", {
		t({ "if err != nil {", '\tlog.Error("' }),
		i(1, "something"),
		t({ '")', "}" }),
		i(0),
	}),
	s("iferr", {
		t({ "if err != nil {", '\tlog.Error("' }),
		i(1, "something"),
		t({ '")', "\treturn err", "}" }),
		i(0),
	}),
	s("mainf", {
		t({ "package main", "", "func main() {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),
})
