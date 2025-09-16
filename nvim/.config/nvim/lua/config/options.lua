-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocal = "\\"

local opt = vim.opt
opt.clipboard = ""
opt.conceallevel = 3 -- Show quote in json file or links in markdown
opt.shiftwidth = 4
opt.tabstop = 4
opt.foldmethod = "indent"
opt.foldlevelstart = 20
opt.iskeyword = opt.iskeyword + "-"
opt.linebreak = true

for c = string.byte('a'), string.byte('z') do
  local lower = string.char(c)
  local upper = string.char(c):upper()

  -- Remap setting a mark
  vim.keymap.set('n', 'm'..lower, 'm'..upper, { noremap = true, silent = true })
  -- Remap jumping to a mark (line)
  vim.keymap.set('n', "'"..lower, "'"..upper, { noremap = true, silent = true })
  -- Remap jumping to a mark (exact place)
  vim.keymap.set('n', '`'..lower, '`'..upper, { noremap = true, silent = true })
end

