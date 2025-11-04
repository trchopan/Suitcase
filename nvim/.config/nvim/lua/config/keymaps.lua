-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- This file is automatically loaded by lazyvim.config.init
local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- map("n", "K", function()
--   return vim.lsp.buf.hover({ border = "single" })
-- end, { desc = "show LSP hover information" })

map("n", "<C-f>w", "*Nciw", { desc = "Change word and repeat", silent = true, remap = false })
-- map("v", "<C-c>c", '"*y', { desc = "Copy to System clipboard", silent = true, remap = false })
map("v", "Y", '"*y', { desc = "Copy to System clipboard", silent = true, remap = false })

map("n", "<leader><Tab>n", "<cmd>tabnew<cr>", { desc = "New Tab", silent = true, remap = false })
map("n", "<leader><Tab><Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab", silent = true, remap = true })

-- Toogle float term
map("n", "<C-\\>", function()
  Snacks.terminal()
end, { desc = "Terminal (cwd)" })

map("t", "<C-\\>", "<cmd>close<cr>", { desc = "Hide Terminal" })

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

map(
  "n",
  "zC",
  "<cmd>let&l:fdl=indent('.')/&sw<cr>",
  { desc = "Fold by indent to current position", silent = true, remap = false }
)

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
