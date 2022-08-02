local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "\\q", ":q<CR>", opt)

k("n", "<Esc><Esc>", ":noh<CR>", opt)

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

k("n", ",,", "ma$a,<Esc>`a", opt)
k("n", ";;", "ma$a;<Esc>`a", opt)

k("n", "<C-f>w", "*Nciw", opt)
k("v", "<C-c>c", '"*y', opt)
k("v", "<C-f><C-f>", 'y:%s?<C-r>"??g<Left><Left>', opt)
k("v", "p", '"_dP', opt)

-- quick vim surround
vim.cmd([[
nmap '' ysiw'
nmap "" ysiw"
nmap }} ysiw}
nmap )) ysiw)
]])

-- Move line up down
vim.cmd([[
nnoremap <A-j> :m .+1<CR>
nnoremap <A-k> :m .-2<CR>
vnoremap <A-j> :m '>+1<CR>gv
vnoremap <A-k> :m '<-2<CR>gv
inoremap <A-j> <Esc>:m .+1<CR>i
inoremap <A-k> <Esc>:m .-2<CR>i
]])

-- Misc keymap for plugins
k("n", "<C-f>r", "<Cmd>lua require('spectre').open()<CR>", opt)
k("n", "<Space>", ":HopWord<CR>", opt)
k("n", "<C-c>k", ":SymbolsOutline<CR>", opt)

