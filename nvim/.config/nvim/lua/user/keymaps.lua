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

k("v", "//", "<Esc><Cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", opt)

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
k("n", "\\r", "<Cmd>LspRestart<CR>", opt)
k("n", "\\p", [[<Cmd>lua vim.lsp.buf.formatting()<CR>]], opt)
k("n", "<C-f>r", "<Cmd>lua require('spectre').open()<CR>", opt)
k("n", "<C-f>f", "<Cmd>Telescope live_grep<CR>", opt)
k("n", "<C-p>", "<Cmd>Telescope find_files<CR>", opt)
k("n", "//", "<Cmd>lua require('Comment.api').toggle_current_linewise()<CR>", opt)
k("n", "<Space>", ":HopWord<CR>", opt)

-- nvim-tree
k("n", "\\\\", "<Cmd>NvimTreeToggle<CR>", opt)
k("n", "`h", "<Cmd>NvimTreeFocus<CR>", opt)

-- barbar
k("n", "<S-x>", ":BufferClose<CR>", opt)
k("n", "<S-z>", ":BufferPick<CR>", opt)
k("n", "<S-l>", ":BufferNext<CR>", opt)
k("n", "<S-h>", ":BufferPrevious<CR>", opt)
k("n", "<A-l>", ":BufferMoveNext<CR>", opt)
k("n", "<A-h>", ":BufferMovePrevious<CR>", opt)
k("n", "\\1", ":BufferGoto 1<CR>", opt)
k("n", "\\2", ":BufferGoto 2<CR>", opt)
k("n", "\\3", ":BufferGoto 3<CR>", opt)
k("n", "\\4", ":BufferGoto 4<CR>", opt)
k("n", "\\5", ":BufferGoto 5<CR>", opt)

-- gitsign
k("n", "<leader>hs", "<Cmd>Gitsigns stage_hunk<CR>", opt)
k("n", "<leader>hr", "<Cmd>Gitsigns reset_hunk<CR>", opt)
k("n", "<leader>hS", "<Cmd>Gitsigns stage_buffer<CR>", opt)
k("n", "<leader>hu", "<Cmd>Gitsigns undo_stage_hunk<CR>", opt)
k("n", "<leader>hR", "<Cmd>Gitsigns reset_buffer<CR>", opt)
k("n", "<leader>hp", "<Cmd>Gitsigns preview_hunk<CR>", opt)
k("n", "<leader>tb", "<Cmd>Gitsigns toggle_current_line_blame<CR>", opt)
k("n", "<leader>td", "<Cmd>Gitsigns toggle_deleted<CR>", opt)
