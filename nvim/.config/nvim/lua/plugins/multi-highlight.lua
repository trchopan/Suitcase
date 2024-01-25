return {
  "arywz/multi-highlight.nvim",
  opts = {
    groups = {
      "#cd5b45",
      "#536878",
      "#08457e",
      "#986960",
      "#013220",
    },
  },
  keys = {
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
