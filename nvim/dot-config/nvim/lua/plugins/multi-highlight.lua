return {
  "arywz/multi-highlight.nvim",
  opts = function()
    local cp = require("catppuccin.palettes").get_palette()

    return {
      groups = {
        cp.red,
        cp.blue,
        cp.green,
        cp.yellow,
        cp.mauve,
        cp.teal,
        cp.peach,
        cp.lavender,
      },
    }
  end,
  config = function(_, opts)
    require("multi-highlight").setup(opts)

    local cp = require("catppuccin.palettes").get_palette()
    for index, bg in ipairs(opts.groups or {}) do
      vim.api.nvim_set_hl(0, "MultiHighlight_" .. index, { fg = cp.base, bg = bg })
    end
  end,
  keys = {
    { "<space>m", false },
    { "<space>M", false },
    {
      "<leader>m",
      function()
        require("multi-highlight").toggle_highlight()
      end,
      desc = "multi highlight",
    },
    {
      "<leader>M",
      function()
        require("multi-highlight").clear()
      end,
      desc = "multi highlight clear",
    },
  },
}
