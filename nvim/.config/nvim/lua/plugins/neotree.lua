return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    "s1n7ax/nvim-window-picker",
  },
  keys = function()
    return {
      { "<leader><leader>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neotree" } },
    }
  end,
  opts = {
    window = {
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
      },
    },
  },
}
