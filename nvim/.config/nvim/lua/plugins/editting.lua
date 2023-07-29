return {
  { "tpope/vim-abolish" }, -- For Subvert and Coercion
  { "mattn/emmet-vim" },
  { "tpope/vim-surround" },
  {
    'echasnovski/mini.splitjoin',
    config = true,
  },
  {
    'echasnovski/mini.move',
    config = true,
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = '',
        right = '',
        down = '',
        up = '',

        -- Move current line in Normal mode
        line_left = '',
        line_right = '',
        line_down = '',
        line_up = '',
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
    end
  }
}
