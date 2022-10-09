local tokyonight_ok, _ = pcall(require, "tokyonight")
if tokyonight_ok then
  vim.g.tokyonight_style = "night"
  vim.g.tokyonight_italic_functions = true
  vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
end

local gruvbox_ok, gruvbox = pcall(require, "gruvbox")
if gruvbox_ok then
  gruvbox.setup({
    undercurl = true,
    underline = true,
    bold = true,
    italic = true,
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true, -- invert background for search, diffs, statuslines and errors
    contrast = "solf", -- can be "hard", "soft" or empty string
    overrides = {},
  })
end

local onedark_ok, onedark = pcall(require, "onedark")
if onedark_ok then
  onedark.setup({
    style = 'darker'
  })
  onedark.load()
end

-- Load the colorscheme
-- vim.cmd[[colorscheme onedark]]
-- vim.cmd [[colorscheme gruvbox]]
-- vim.cmd [[colorscheme tokyonight]]
vim.cmd [[colorscheme melange]]

local theme_index = 1

function _rotate_themes()
  local themes = { "tokyonight-moon", "gruvbox", "onedark", "melange" }
  local next_theme = themes[theme_index]
  vim.cmd('colorscheme ' .. next_theme)
  theme_index = theme_index < #themes and theme_index + 1 or 1
  print(next_theme)
end

vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>lua _rotate_themes()<CR>", { noremap = true, silent = true })
