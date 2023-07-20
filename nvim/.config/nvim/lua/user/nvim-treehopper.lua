local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "vv", "<Cmd>lua require('tsht').nodes()<CR>", opt)
k("n", "vc", "<Cmd>lua require('tsht').move().<CR>", opt)
