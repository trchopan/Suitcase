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
map({ "n", "v" }, "<leader>cy", function()
  local file = vim.fn.expand("%:.")

  local mode = vim.fn.mode()

  local start_line, end_line

  if mode == "v" or mode == "V" or mode == "\22" then
    -- Visual mode (char, line, or block)
    start_line = vim.fn.line("v")
    end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
  else
    -- Normal mode
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  local ref
  if start_line == end_line then
    ref = string.format("%s:%d", file, start_line)
  else
    ref = string.format("%s:%d-%d", file, start_line, end_line)
  end

  vim.fn.setreg("+", ref)
  print("Copied: " .. ref)
end, { desc = "Copy file:line or file:line-line reference" })

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

local function global_mark(prefix)
  local key = vim.fn.getcharstr()
  if key:match("^[a-z]$") then
    key = key:upper()
  end
  return prefix .. key
end

map("n", "m", function()
  return global_mark("m")
end, { expr = true, desc = "Set Global Mark" })

map("n", "`", function()
  return global_mark("`")
end, { expr = true, desc = "Jump to Global Mark" })

map("n", "'", function()
  return global_mark("'")
end, { expr = true, desc = "Jump to Global Mark (Line)" })

for i = 1, 9 do
  map("n", "<leader>" .. i, function()
    require("bufferline").go_to(i, true)
  end, { desc = "Go to Buffer " .. i })
end

map("n", "<leader>0", "<cmd>BufferLineGoToBuffer -1<cr>", { desc = "Go to Last Buffer" })

-- My Scripts

map("n", "<leader>du", function()
  require("mylua.url_to_markdown").download_at_cursor()
end, { desc = "Download URL at cursor to markdown" })

map("n", "<leader>cb", function()
  vim.cmd("FormatCodeBlockLLM")
end, { desc = "Format code block with LLM" })

map("n", "<leader>dk", function()
  vim.ui.input({ prompt = "Search term: " }, function(search_term)
    if search_term then
      vim.ui.input({ prompt = "Package (optional): " }, function(package)
        require("mylua.mix_usage_rules").search_docs_buffer(search_term, package)
      end)
    end
  end)
end, { desc = "Search mix usage rules" })

map("n", "<leader>rr", function()
  vim.cmd("normal! mF") -- Mark current position with global mark 'F'
  snacksLocal.bufdelete()
  vim.cmd("normal! `F") -- Go to the global mark 'F' (which will reopen the file at the marked position)
end, { desc = "Reopen current buffer" })

map("n", "<leader>up", function()
  vim.cmd.Copilot("toggle")
end, { desc = "Toggle Copilot" })

map("n", "<leader>uc", function()
  vim.ui.select({ "personal", "work" }, { prompt = "Copilot provider" }, function(choice)
    if choice then
      vim.cmd("CopilotProvider " .. choice)
    end
  end)
end, { desc = "Select Copilot provider" })
