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
