return {
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup()
  end,
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open Oil to edit filesystem in buffer" }
  }
}
