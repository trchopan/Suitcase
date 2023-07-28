return {
  "akinsho/bufferline.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  keys = {
    {
      "X",
      function()
        require("mini.bufremove").delete(0, false)
      end,
      desc = "Delete Buffer",
    },
    { "<leader>bK", "<cmd>BufferLineCloseOthers<cr>", desc = "Delete Other Buffers" },
  },
}
