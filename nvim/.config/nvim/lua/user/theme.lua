vim.g.tokyonight_style = "storm"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }

vim.g.gruvbox_baby_function_style = "NONE"
vim.g.gruvbox_baby_keyword_style = "italic"
vim.g.gruvbox_baby_background_color = "dark"

require('onedark').setup {
    style = 'darker'
}
require('onedark').load()

-- Load the colorscheme
-- vim.cmd[[colorscheme onedark]]
vim.cmd [[colorscheme gruvbox]]
