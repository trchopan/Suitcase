-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dart",
  command = "setlocal shiftwidth=2 tabstop=2"
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  command = "setlocal shiftwidth=4 tabstop=4"
})
