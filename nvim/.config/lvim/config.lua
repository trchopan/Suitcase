-- general
vim.opt.timeoutlen = 2000
vim.opt.clipboard = ""
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 20
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.colorscheme = "onedarker"

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = ""
-- add your own keymapping
lvim.keys.normal_mode["`"] = false
lvim.keys.normal_mode["<S-x>"] = ":BufferClose<CR>"
lvim.keys.normal_mode["\\\\"] = "<Cmd>NvimTreeToggle<CR>"
lvim.keys.normal_mode["`h"] = "<Cmd>NvimTreeFocus<CR>"
lvim.keys.normal_mode["\\r"] = "<Cmd>LspRestart<CR>"
lvim.keys.normal_mode["\\p"] = [[<Cmd>lua vim.lsp.buf.formatting()<CR>]]
lvim.keys.normal_mode["<A-l>"] = ":BufferMoveNext<CR>"
lvim.keys.normal_mode["<A-h>"] = ":BufferMovePrevious<CR>"
lvim.keys.normal_mode["\\1"] = ":BufferGoto 1<CR>"
lvim.keys.normal_mode["\\2"] = ":BufferGoto 2<CR>"
lvim.keys.normal_mode["\\3"] = ":BufferGoto 3<CR>"
lvim.keys.normal_mode["\\4"] = ":BufferGoto 4<CR>"
lvim.keys.normal_mode["\\5"] = ":BufferGoto 5<CR>"
lvim.keys.normal_mode["<C-f>f"] = "<Cmd>Telescope live_grep<CR>"
lvim.keys.normal_mode["//"] = "<Cmd>lua require('Comment.api').toggle_current_linewise()<CR>"
lvim.keys.normal_mode["<C-f>w"] = "*Nciw"
lvim.keys.normal_mode["<Esc><Esc>"] = ":noh<CR>"
lvim.keys.normal_mode[",,"] = "ma$a,<Esc>`a"
lvim.keys.normal_mode[";;"] = "ma$a;<Esc>`a"
lvim.keys.normal_mode["]]"] = "ysiw]"
lvim.keys.normal_mode["<Space>"] = ":HopWord<CR>"
lvim.keys.normal_mode["<C-f>r"] = "<Cmd>lua require('spectre').open()<CR>"
lvim.keys.normal_mode["<C-p>"] = "<Cmd>Telescope find_files<CR>"

lvim.keys.insert_mode["{{"] = "{{}}<Esc><Left>i"
lvim.keys.insert_mode["{}"] = "{}<Esc>i"
lvim.keys.insert_mode["{}<CR>"] = "{}<Esc>i<CR><Esc>==O"
lvim.keys.insert_mode["{}<CR><CR>"] = "{},<Esc><Left>i<CR><Esc>==O"
lvim.keys.insert_mode["()"] = "()<Esc>i"
lvim.keys.insert_mode["()<Space>"] = "()<Space>"
lvim.keys.insert_mode["();"] = "();"
lvim.keys.insert_mode["()<CR>"] = "()<Esc>i<CR><Esc>==O"
lvim.keys.insert_mode["<>"] = "<><Esc>i"
lvim.keys.insert_mode["[]"] = "[]<Esc>i"
lvim.keys.insert_mode["[]<CR>"] = "[]<Esc>i<CR><Esc>==O"
lvim.keys.insert_mode["``"] = "``<Esc>i"
lvim.keys.insert_mode["```"] = "```"
lvim.keys.insert_mode["``<CR>"] = "``<Esc>i<CR><Esc>==O"
lvim.keys.insert_mode['""'] = '""<Esc>i'
lvim.keys.insert_mode['"""'] = '"""'
lvim.keys.insert_mode["''"] = "''<Esc>i"

lvim.keys.visual_mode["<C-c>c"] = '"*y'
lvim.keys.visual_mode["//"] = "<Esc><Cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>"

vim.cmd([[
  nmap '' ysiw'
  nmap "" ysiw"
  nmap }} ysiw}
  nmap )) ysiw)
]])

-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = false
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
-- }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.active = true
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = false
lvim.builtin.dap.active = false
lvim.builtin.autopairs.active = false
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0
lvim.builtin.nvimtree.setup.open_on_tab = true
lvim.builtin.nvimtree.setup.auto_close = false
lvim.builtin.nvimtree.setup.filters.custom = { ".git", "node_modules", ".cache", ".DS_Store" }

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"css",
	"rust",
	"java",
	"yaml",
	"go",
	"haskell",
}

-- lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---@usage Select which servers should be configured manually. Requires `:LvimCacheRest` to take effect.
-- See the full default list `:lua print(vim.inspect(lvim.lsp.override))`
vim.list_extend(lvim.lsp.override, { "vuels" })

-- ---@usage setup a server -- see: https://www.lunarvim.org/languages/#overriding-the-default-configuration
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
require("lvim.lsp.manager").setup("volar", {})

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
	{
		command = "stylua",
		filetypes = { "lua" },
	},
	{
		-- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
		command = "prettier",
		---@usage arguments to pass to the formatter
		-- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
		-- extra_args = { "--print-with", "100" },
		---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
		filetypes = { "vue", "typescript", "typescriptreact", "javascript", "json", "yaml" },
	},
})

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--severity", "warning" },
--   },
--   {
--     command = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }

-- Additional Plugins
lvim.plugins = {
	{ "folke/tokyonight.nvim" },
	{ "arcticicestudio/nord-vim" },
	{ "tpope/vim-surround" },
	{
		"phaazon/hop.nvim",
		branch = "v1",
		event = "BufRead",
		config = function()
			require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
		end,
	},
	{
		"windwp/nvim-spectre",
		event = "BufRead",
		config = function()
			require("spectre").setup()
		end,
	},
	{
		"ethanholz/nvim-lastplace",
		event = "BufRead",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = {
					"gitcommit",
					"gitrebase",
					"svn",
					"hgcommit",
				},
				lastplace_open_folds = true,
			})
		end,
	},
	{ "mattn/emmet-vim" },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- lvim.autocommands.custom_groups = {
-- { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
-- }
