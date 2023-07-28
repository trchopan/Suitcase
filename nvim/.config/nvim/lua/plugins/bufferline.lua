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

    -- Below moving keymap is mapped again in alacrity to sync up with browser tab move
    { "<leader>tl", ":BufferLineMoveNext<CR>",        desc = "Move Buffer Next", silent = true },
    { "<leader>th", ":BufferLineMovePrev<CR>",        desc = "Move Buffer Previous", silent = true },
  },
}
