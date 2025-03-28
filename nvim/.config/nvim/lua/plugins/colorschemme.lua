return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        neotree = true,
        treesitter = true,
        mini = true,
        symbols_outline = true,
      },
      styles = {
        comments = { "italic" },
        properties = { "italic" },
        functions = { "bold" },
        keywords = { "italic" },
        operators = { "bold" },
        conditionals = { "bold" },
        loops = { "bold" },
        booleans = { "bold", "italic" },
        numbers = {},
        types = {},
        strings = {},
        variables = {},
      },
      custom_highlights = function(colors)
        return {
          CmpBorder = { fg = colors.flamingo },
          VertSplit = { fg = colors.flamingo },
        }
      end,
    },
  },
}
