return {
  "L3MON4D3/LuaSnip",
  opts = function()
    local ls = require("luasnip")

    local console_log_snippet = ls.parser.parse_snippet({ trig = "clg" }, "console.log('👉', ${1:message});")

    ls.add_snippets("javascript", { console_log_snippet })
    ls.add_snippets("typescript", { console_log_snippet })
  end,
}
