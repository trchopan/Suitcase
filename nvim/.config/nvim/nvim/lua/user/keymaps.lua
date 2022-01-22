local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k('n', "<S-x>", ":BufferClose<CR>", opt)
k('n', "\\q", ":q<CR>", opt)
k('n', "\\\\", "<Cmd>NvimTreeToggle<CR>", opt)
k('n', "`h", "<Cmd>NvimTreeFocus<CR>", opt)
k('n', "\\r", "<Cmd>LspRestart<CR>", opt)
k('n', "\\p", [[<Cmd>lua vim.lsp.buf.formatting()<CR>]], opt)
k('n', "<S-l>", ":BufferNext<CR>", opt)
k('n', "<S-h>", ":BufferPrevious<CR>", opt)
k('n', "<A-l>", ":BufferMoveNext<CR>", opt)
k('n', "<A-h>", ":BufferMovePrevious<CR>", opt)
k('n', "\\1", ":BufferGoto 1<CR>", opt)
k('n', "\\2", ":BufferGoto 2<CR>", opt)
k('n', "\\3", ":BufferGoto 3<CR>", opt)
k('n', "\\4", ":BufferGoto 4<CR>", opt)
k('n', "\\5", ":BufferGoto 5<CR>", opt)
k('n', "<C-f>f", "<Cmd>Telescope live_grep<CR>", opt)
k('n', "//", "<Cmd>lua require('Comment.api').toggle_current_linewise()<CR>", opt)
k('n', "<C-f>w", "*Nciw", opt)
k('n', "<Esc><Esc>", ":noh<CR>", opt)
k('n', ",,", "ma$a,<Esc>`a", opt)
k('n', ";;", "ma$a;<Esc>`a", opt)
k('n', "]]", "ysiw]", opt)
k('n', "<Space>", ":HopWord<CR>", opt)
k('n', "<C-f>r", "<Cmd>lua require('spectre').open()<CR>", opt)
k('n', "<C-p>", "<Cmd>Telescope find_files<CR>", opt)

k('i', "{{", "{{}}<Esc><Left>i", opt)
k('i', "{}", "{}<Esc>i", opt)
k('i', "{}<CR>", "{}<Esc>i<CR><Esc>==O", opt)
k('i', "{}<CR><CR>", "{},<Esc><Left>i<CR><Esc>==O", opt)
k('i', "()", "()<Esc>i", opt)
k('i', "()<Space>", "()<Space>", opt)
k('i', "();", "();", opt)
k('i', "()<CR>", "()<Esc>i<CR><Esc>==O", opt)
k('i', "<>", "<><Esc>i", opt)
k('i', "[]", "[]<Esc>i", opt)
k('i', "[]<CR>", "[]<Esc>i<CR><Esc>==O", opt)
k('i', "``", "``<Esc>i", opt)
k('i', "```", "```", opt)
k('i', "``<CR>", "``<Esc>i<CR><Esc>==O", opt)
k('i', '""', '""<Esc>i', opt)
k('i', '"""', '"""', opt)
k('i', "''", "''<Esc>i", opt)

k('v', "<C-c>c", '"*y', opt)
k('v', "//", "<Esc><Cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", opt)

vim.cmd([[
nmap '' ysiw'
nmap "" ysiw"
nmap }} ysiw}
nmap )) ysiw)
nnoremap <A-j> :m .+1<CR>
nnoremap <A-k> :m .-2<CR>
vnoremap <A-j> :m '>+1<CR>gv
vnoremap <A-k> :m '<-2<CR>gv
inoremap <A-j> <Esc>:m .+1<CR>i
inoremap <A-k> <Esc>:m .-2<CR>i
]])

