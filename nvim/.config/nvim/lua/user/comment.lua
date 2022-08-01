require'nvim-treesitter.configs'.setup {
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  }
}

local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "//", "<Cmd>lua require('Comment.api').toggle_current_linewise()<CR>", opt)
k("v", "//", "<Esc><Cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", opt)
k("n", "C-/", "<Esc><Cmd>lua require('Comment.api').toggle_current_blockwise()<CR>", opt)
k("v", "C-/", "<Esc><Cmd>lua require('Comment.api').toggle_blockwise_op(vim.fn.visualmode())<CR>", opt)
