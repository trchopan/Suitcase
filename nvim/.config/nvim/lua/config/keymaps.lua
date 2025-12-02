local snacksLocal = Snacks

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then
    opts.remap = nil
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Editing tricks
map("n", "<C-f>w", "*Nciw", { desc = "Change word and repeat", silent = true, remap = false })
map("v", "Y", '"*y', { desc = "Copy to System clipboard", silent = true, remap = false })
map(
  "n",
  "zC",
  "<cmd>let&l:fdl=indent('.')/&sw<cr>",
  { desc = "Fold by indent to current position", silent = true, remap = false }
)

-- better indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- lazygit
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function()
    snacksLocal.lazygit()
  end, { desc = "Lazygit (cwd)" })
end

-- windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- Snacks toggles
snacksLocal.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
snacksLocal.toggle.zen():map("<leader>uz")
snacksLocal.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
snacksLocal.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
snacksLocal.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
snacksLocal.toggle.diagnostics():map("<leader>ud")
snacksLocal.toggle.line_number():map("<leader>ul")
snacksLocal.toggle
  .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
  :map("<leader>uc")
snacksLocal.toggle
  .option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
  :map("<leader>uA")
snacksLocal.toggle.treesitter():map("<leader>uT")
snacksLocal.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
snacksLocal.toggle.dim():map("<leader>uD")
snacksLocal.toggle.animate():map("<leader>ua")
snacksLocal.toggle.indent():map("<leader>ug")
snacksLocal.toggle.scroll():map("<leader>uS")
snacksLocal.toggle.profiler():map("<leader>dpp")
snacksLocal.toggle.profiler_highlights():map("<leader>dph")

if vim.lsp.inlay_hint then
  snacksLocal.toggle.inlay_hints():map("<leader>uh")
end

-- Toogle float term
map("n", "<C-\\>", function()
  snacksLocal.terminal()
end, { desc = "Terminal (cwd)" })

map("t", "<C-\\>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- Buffer jump by tick
local keymaps = {
  { key = "'a", buf = 1, desc = "Go to 1st buffer" },
  { key = "'s", buf = 2, desc = "Go to 2nd buffer" },
  { key = "'d", buf = 3, desc = "Go to 3rd buffer" },
  { key = "'f", buf = 4, desc = "Go to 4th buffer" },
  { key = "'g", buf = 5, desc = "Go to 5th buffer" },
}

for _, keymap in ipairs(keymaps) do
  vim.keymap.set("n", keymap.key, function()
    require("bufferline").go_to(keymap.buf, true)
  end, { desc = keymap.desc })
end

-- My Scripts

map("n", "<leader>du", function()
  require("mylua.url_to_markdown").download_at_cursor()
end, { desc = "Download URL at cursor to markdown" })

map("n", "<leader>dk", function()
  vim.ui.input({ prompt = "Search term: " }, function(search_term)
    if search_term then
      vim.ui.input({ prompt = "Package (optional): " }, function(package)
        require("mylua.mix_usage_rules").search_docs_buffer(search_term, package)
      end)
    end
  end)
end, { desc = "Search mix usage rules" })
