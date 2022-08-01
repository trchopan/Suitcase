vim.g.tokyonight_style = "storm"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }

vim.g.gruvbox_baby_function_style = "NONE"
vim.g.gruvbox_baby_keyword_style = "italic"
vim.g.gruvbox_baby_background_color = "dark"

local colors = require("gruvbox-baby.colors").config()
vim.g.gruvbox_baby_highlights = {
  Comment = { fg = colors.orange },
  SpecialComment = { fg = colors.orange },
}

require("onedarkpro").setup({
  theme = "onedark_dark",
})

-- local config = require("gruvbox-baby.config")
-- local colors = require("gruvbox-baby.colors")
-- local c = colors.config(config)
-- vim.g.gruvbox_baby_highlights = {
--   Normal = { fg = "#c2bbb5", bg = c.background, style = config.comment_style },
--   Comment = { fg = "#c2bbb5", bg = c.background, style = config.comment_style },
--   SpecialComment ={ fg = "#c2bbb5", bg = c.background,  style = config.comment_style },
-- }


-- Load the colorscheme
-- vim.cmd[[colorscheme onedarkpro]]
vim.cmd [[colorscheme gruvbox-baby]]
