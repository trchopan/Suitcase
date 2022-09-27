local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "<Esc><Esc>", ":noh<CR>", opt)
k("n", "<leader>bK", ":BufferCloseAllButCurrent<CR>", opt)

-- Brackets
k("i", "{{", "{{}}<Esc><Left>i", opt)
k("i", "{}", "{}<Esc>i", opt)
k("i", "{}<CR>", "{}<Esc>i<CR><Esc>==O", opt)
k("i", "{}<CR><CR>", "{},<Esc><Left>i<CR><Esc>==O", opt)
k("i", "()", "()<Esc>i", opt)
k("i", "()<Space>", "()<Space>", opt)
k("i", "();", "();", opt)
k("i", "()<CR>", "()<Esc>i<CR><Esc>==O", opt)
k("i", "<>", "<><Esc>i", opt)
k("i", "[]", "[]<Esc>i", opt)
k("i", "[]<CR>", "[]<Esc>i<CR><Esc>==O", opt)
k("i", "``", "``<Esc>i", opt)
k("i", "```", "```", opt)
k("i", "``<CR>", "``<Esc>i<CR><Esc>==O", opt)
k("i", '""', '""<Esc>i', opt)
k("i", '"""', '"""', opt)
k("i", "''", "''<Esc>i", opt)
k("i", "||", "||<Esc>i", opt)

k("n", ",,", "ma$a,<Esc>`a", opt)
k("n", ";;", "ma$a;<Esc>`a", opt)

k("n", "<C-f>w", "*Nciw", opt)
k("v", "<C-f>w", '"yy?<C-r>y<CR>N', opt)
k("v", "<C-c>c", '"*y', opt)
k("v", "p", '"_dP', opt) -- paste without yanking current selection

-- quick vim surround
vim.cmd([[
nmap '' ysiw'
nmap "" ysiw"
nmap }} ysiw}
nmap )) ysiw)
]])

-- Move line up down. On some terminal may need to change to <A-j> and <A-k>.
vim.cmd([[
" nnoremap <A-j> :m .+1<CR>
nnoremap ∆ :m .+1<CR>
nnoremap ˚ :m .-2<CR>
vnoremap ∆ :m '>+1<CR>gv
vnoremap ˚ :m '<-2<CR>gv
inoremap ∆ <Esc>:m .+1<CR>i
inoremap ˚ <Esc>:m .-2<CR>i
]])

-- Misc keymap for plugins
k("n", "<C-f>r", "<Cmd>lua require('spectre').open()<CR>", opt)
