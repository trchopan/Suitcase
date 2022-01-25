vim.o.backup = false
vim.o.cmdheight = 1
vim.o.completeopt = "menuone,noselect"
vim.o.conceallevel = 0
vim.o.fileencoding = "utf-8"
vim.o.foldmethod = "indent"
vim.o.foldlevelstart = 20
vim.o.pumheight = 10
vim.o.showtabline = 2
vim.o.smartindent = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.cursorline = true
vim.o.numberwidth = 4
vim.o.wrap = false
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.guifont = "monospace:h17"
vim.o.hlsearch = true
vim.o.number = true
vim.o.showmode = false
vim.o.relativenumber = false
vim.o.hidden = true
vim.o.writebackup = false
vim.o.mouse = "a"
vim.o.breakindent = true
vim.opt.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
-- vim.o.updatetime = 300
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
vim.o.background = "dark"

vim.api.nvim_exec(
	[[
  set whichwrap+=<,>,[,],h,l"
  set iskeyword+=-

  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
  ]],
	false
)

vim.cmd([[colorscheme onedarker]])

local theme = vim.fn.system("defaults read -g AppleInterfaceStyle")
if string.find(theme, "Dark") then
	vim.o.background = "dark"
	vim.cmd([[colorscheme onedarker]])
else
	vim.o.background = "light"
	vim.cmd([[colorscheme morning]])
end
