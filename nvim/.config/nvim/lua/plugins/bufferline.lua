return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
    opts.options = {
      show_buffer_close_icons = false,
      show_close_icon = false,
      always_show_bufferline = true,
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(_, _, diag)
        local icons = LazyVim.config.icons.diagnostics
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
      },
    }
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
  },
}
