return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "terafox",
      -- colorscheme = "catppuccin",
      -- colorscheme = "tokyonight",
    },
  },
  { "ellisonleao/gruvbox.nvim" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
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
    }
  },
  {
    "EdenEast/nightfox.nvim",
    name = "nightfox",
    priority = 1000,
    opts = {
      options = {
        styles = {
          comments = "italic",
          conditionals = "bold",
          constants = "NONE",
          functions = "bold",
          keywords = "italic",
          numbers = "NONE",
          operators = "bold",
          strings = "NONE",
          types = "NONE",
          variables = "NONE",
        },
      },
      groups = {
        terafox = {
          VertSplit = { bg = "bg1", fg = "#005b03" }
        },
        nightfox = {
          VertSplit = { bg = "bg1", fg = "#0d4e6c" }
        },
      }
    }
  },
}
