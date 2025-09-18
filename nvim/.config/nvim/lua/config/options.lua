-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocal = "\\"

vim.opt.clipboard = ""
vim.opt.conceallevel = 3 -- Show quote in json file or links in markdown
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 20
vim.opt.iskeyword = vim.opt.iskeyword + "-"
vim.opt.linebreak = true
vim.opt.undolevels = 1000

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

