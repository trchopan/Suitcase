local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "<Esc><Esc>", ":noh<CR>", opt)
k("n", "<leader>bK", ":BufferCloseAllButCurrent<CR>", opt)

k("n", "<C-f>w", "*Nciw", opt)
k("v", "<C-f>w", '"yy?<C-r>y<CR>N', opt)
k("v", "<C-c>c", '"*y', opt)
k("v", "p", '"_dP', opt) -- paste without yanking current selection

vim.cmd([[
" change without yanking by put it to black hole register "_
nnoremap c "_c
]])

-- quick vim surround
vim.cmd([[
nmap '' ysiw'
nmap "" ysiw"
nmap }} ysiw}
nmap )) ysiw)
]])

-- Misc keymap for plugins
k("n", "<C-f>r", "<Cmd>lua require('spectre').open()<CR>", opt)
k("n", "<leader>rr", "<Cmd>LspRestart<CR>", opt)
k("n", "vv", "<Cmd>lua require('tsht').nodes()<CR>", opt)

-- Rust
k("n", "<leader>rsc", ":e Cargo.toml<CR>", opt)

vim.g.is_wrap = false

function _toggleWrap()
    if vim.g.is_wrap then
        vim.g.is_wrap = false
        vim.cmd("set nowrap")
    else
        vim.g.is_wrap = true
        vim.cmd("set wrap")
    end
end 

k("n", "<leader>w", "<cmd>lua _toggleWrap()<CR>", opt)
