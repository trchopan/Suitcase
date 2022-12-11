local tokyonight_ok, _ = pcall(require, "tokyonight")
if tokyonight_ok then
    vim.g.tokyonight_style = "night"
    vim.g.tokyonight_italic_functions = true
    vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
end

local onedark_ok, onedark = pcall(require, "onedark")
if onedark_ok then
    onedark.setup({
        style = 'darker'
    })
    onedark.load()
end

local catppuccin_ok, catppuccin = pcall(require, "catppuccin")
if catppuccin_ok then
    catppuccin.setup({
        flavour = 'mocha',
        highlight_overrides = {
            all = function(colors)
                local visible_bg = "#1e1e2e"
                local current_bg = "#45475a"
                return {
                    BufferVisible = { bg = visible_bg, fg = "#cdd6f4" },
                    BufferVisibleIndex = { bg = visible_bg, fg = colors.blue },
                    BufferVisibleMod = { bg = visible_bg, fg = colors.yellow },
                    BufferVisibleSign = { bg = visible_bg, fg = colors.blue },
                    BufferVisibleTarget = { bg = visible_bg, fg = colors.red },

                    BufferCurrent = { bg = "#45475a", fg = colors.flamingo },
                    BufferCurrentIndex = { bg = current_bg, fg = colors.blue },
                    BufferCurrentMod = { bg = current_bg, fg = colors.yellow },
                    BufferCurrentSign = { bg = current_bg, fg = colors.blue },
                    BufferCurrentTarget = { bg = current_bg, fg = colors.red },
                }
            end,
        },
    })
end


-- Load the colorscheme
-- vim.cmd[[colorscheme onedark]]
-- vim.cmd [[colorscheme gruvbox]]
-- vim.cmd [[colorscheme tokyonight]]
vim.cmd.colorscheme "catppuccin"

local theme_index = 1

function _rotate_themes()
    local themes = { "tokyonight-moon", "melange", "onedark", "catppuccin" }
    local next_theme = themes[theme_index]
    vim.cmd('colorscheme ' .. next_theme)
    theme_index = theme_index < #themes and theme_index + 1 or 1
    print(next_theme)
end

vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>lua _rotate_themes()<CR>", { noremap = true, silent = true })
