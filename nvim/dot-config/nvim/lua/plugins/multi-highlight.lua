return {
  "arywz/multi-highlight.nvim",
  opts = {
    groups = {
      "#cd5b45",
      "#0091ff",
      "#36ff44",
      "#986960",
      "#013220",
    },
  },
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
