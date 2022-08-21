local status_ok, trouble = pcall(require, "trouble")
if not status_ok then
  return
end

trouble.setup()

local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "gr", "<cmd>TroubleToggle lsp_references<cr>", opt)
k("n", "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", opt)
k("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", opt)
