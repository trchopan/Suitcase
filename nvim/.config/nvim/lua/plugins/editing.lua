return {
  { "mattn/emmet-vim" },
  "tpope/vim-surround",
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      enable_check_bracket_line = false,
      fast_wrap = {
        map = "<C-e>",
      },
    },
  },
  {
    "johmsalas/text-case.nvim",
    event = "VeryLazy",
    config = function()
      require("textcase").setup()
      require("telescope").load_extension("textcase")
    end,
    keys = {
      { mode = { "n", "v" }, "ga.", "<cmd>TextCaseOpenTelescope<CR>", desc = "Telescope Text Case" },
    },
  },
  {
    "nvim-mini/mini.splitjoin",
    config = true,
  },
  {
    "nvim-mini/mini.move",
    config = true,
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = "",
        right = "",
        down = "",
        up = "",

        -- Move current line in Normal mode
        line_left = "",
        line_right = "",
        line_down = "",
        line_up = "",
      },
    },
    keys = function()
      return {
        --
        { mode = { "n" }, "∆", "<cmd>lua MiniMove.move_line('down')<cr>", desc = "Move down" },
        { mode = { "n" }, "˚", "<cmd>lua MiniMove.move_line('up')<cr>", desc = "Move up" },
        { mode = { "n" }, "˙", "<cmd>lua MiniMove.move_line('left')<cr>", desc = "Move left" },
        { mode = { "n" }, "¬", "<cmd>lua MiniMove.move_line('right')<cr>", desc = "move right" },

        --
        { mode = { "x" }, "∆", "<cmd>lua MiniMove.move_selection('down')<cr>", desc = "Move down" },
        { mode = { "x" }, "˚", "<cmd>lua MiniMove.move_selection('up')<cr>", desc = "Move up" },
        { mode = { "x" }, "˙", "<cmd>lua MiniMove.move_selection('left')<cr>", desc = "Move left" },
        { mode = { "x" }, "¬", "<cmd>lua MiniMove.move_selection('right')<cr>", desc = "move right" },
      }
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace",
      },
    },
  },
}
