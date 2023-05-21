local on_attach = require("user.lsp.handlers").on_attach

require("flutter-tools").setup {
    lsp = {
        on_attach = on_attach
    }
} -- use defaults

require("telescope").load_extension("flutter")

local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap
k("n", "<leader>fp", "<cmd>Telescope flutter commands<CR>", opt)
