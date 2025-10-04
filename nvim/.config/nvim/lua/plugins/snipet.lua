return {
  "L3MON4D3/LuaSnip",
  opts = function()
    local ls = require("luasnip")

    local console_log_snippet = ls.parser.parse_snippet({ trig = "clg" }, "console.log('👉 ${1:name}', ${2:detail});")

    ls.add_snippets("javascript", { console_log_snippet })
    ls.add_snippets("typescript", { console_log_snippet })

    local if_block_snippet =
      ls.parser.parse_snippet({ trig = "ifdo" }, "<%= if ${1:condition} do %>\n  ${2:content}\n<% end %>")

    local fordo_block_snippet = ls.parser.parse_snippet(
      { trig = "fordo" },
      "<%= for ${1:item} <- ${2:enumerable} do %>\n  ${3:content}\n<% end %>"
    )

    local tap_snippet = ls.parser.parse_snippet({ trig = "tap" }, 'tap(&IO.inspect(&1${1:property}, label: "label"))')
    local elixir_snippets = { if_block_snippet, fordo_block_snippet }
    ls.add_snippets("heex", elixir_snippets)
    ls.add_snippets("elixir", vim.list_extend({ tap_snippet }, elixir_snippets))

    local script_tag_snippet = ls.parser.parse_snippet({ trig = "script" }, '<script lang="ts">\n$1\n</script>')
    ls.add_snippets("svelte", { console_log_snippet, script_tag_snippet })
    ls.add_snippets("vue", { console_log_snippet, script_tag_snippet })
  end,
}
