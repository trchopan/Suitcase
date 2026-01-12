return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  event = "VeryLazy",
  opts = {
    options = {
      indicator = {
        style = "underline",
      },
      show_buffer_close_icons = false,
      show_close_icon = false,
      always_show_bufferline = true,
     -- stylua: ignore
      close_command = function(n) Snacks.bufdelete(n) end,
      -- stylua: ignore
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = "nvim_lsp",
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
        {
          filetype = "snacks_layout_box",
        },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  end,
  keys = {
    {
      "X",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    { "<leader>bK", "<cmd>BufferLineCloseOthers<cr>", desc = "Delete Other Buffers" },

    -- Below moving keymap is mapped again in alacrity to sync up with browser tab move
    { "<leader>br", ":BufferLineMoveNext<CR>", desc = "Move Buffer Next", silent = true },
    { "<leader>bl", ":BufferLineMovePrev<CR>", desc = "Move Buffer Previous", silent = true },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },

    -- Assume there is nomore than 10 buffer. Move first just move it 10 times.
    {
      "<leader>bf",
      function()
        for _ = 1, 10 do
          vim.cmd("BufferLineMovePrev")
        end
      end,
      desc = "Move Buffer To First",
      silent = true,
    },
  },
}
