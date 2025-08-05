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
map("v", "<C-c>c", '"*y', { desc = "Copy to System clipboard", silent = true, remap = false })
map("v", "<C-c>p", '"py', { desc = "Copy to register p", silent = true, remap = false })
map("n", "<C-P>", '"pp', { desc = "Paste from register p", silent = true, remap = false })

map("n", "<leader><Tab>n", "<cmd>tabnew<cr>", { desc = "New Tab", silent = true, remap = false })
map("n", "<leader><Tab><Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab", silent = true, remap = true })

map("n", "<C-t>fd", function()
  vim.opt.foldmethod = "indent"
end, { desc = "Fold by indent" })

-- Toogle float term
map("n", "<C-\\>", function()
  Snacks.terminal()
end, { desc = "Terminal (cwd)" })

map("t", "<C-\\>", "<cmd>close<cr>", { desc = "Hide Terminal" })

map(
  "n",
  "zC",
  "<cmd>let&l:fdl=indent('.')/&sw<cr>",
  { desc = "Fold by indent to current position", silent = true, remap = false }
)
