return {
  "L3MON4D3/LuaSnip",
  opts = function()
    local ls = require("luasnip")

    local console_log_snippet = ls.parser.parse_snippet({ trig = "clg" }, "console.log('👉 ${1:name}'${2:detail});")
    local script_tag_snippet = ls.parser.parse_snippet({ trig = "script" }, '<script lang="ts">\n$1\n</script>')

    ls.add_snippets("javascript", { console_log_snippet })
    ls.add_snippets("typescript", { console_log_snippet })
    -- ls.add_snippets("svelte", { console_log_snippet, script_tag_snippet })
    -- ls.add_snippets("vue", { console_log_snippet, script_tag_snippet })

    -- vim.keymap.set({ "i" }, "<C-K>", function()
    --   ls.expand()
    -- end, { silent = true })
    --
    -- vim.keymap.set({ "i", "s" }, "<C-L>", function()
    --   ls.jump(1)
    -- end, { silent = true })
    --
    -- vim.keymap.set({ "i", "s" }, "<C-J>", function()
    --   ls.jump(-1)
    -- end, { silent = true })
    --
    -- vim.keymap.set({ "i", "s" }, "<C-E>", function()
    --   if ls.choice_active() then
    --     ls.change_choice(1)
    --   end
    -- end, { silent = true })
  end,
}
