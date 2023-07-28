return {
  { "tpope/vim-abolish" }, -- For Subvert and Coercion
  { "mattn/emmet-vim" },
  {
    'booperlv/nvim-gomove',
    config = true,
    opts = {
      -- whether or not to map default key bindings, (true/false)
      map_defaults = false,
      -- whether or not to reindent lines moved vertically (true/false)
      reindent = true,
      -- whether or not to undojoin same direction moves (true/false)
      undojoin = true,
      -- whether to not to move past end column when moving blocks horizontally, (true/false)
      move_past_end_col = false,
    },
    keys = function()
      return {
        --
        { mode = { "n" }, "˙", "<Plug>GoNSMLeft", desc = "Move left" },
        { mode = { "n" }, "∆", "<Plug>GoNSMDown", desc = "Move down" },
        { mode = { "n" }, "˚", "<Plug>GoNSMUp", desc = "Move up" },
        { mode = { "n" }, "¬", "<Plug>GoNSMRight", desc = "move right" },

        --
        { mode = { "x" }, "˙", "<Plug>GoVSMLeft", desc = "Move left" },
        { mode = { "x" }, "∆", "<Plug>GoVSMDown", desc = "Move down" },
        { mode = { "x" }, "˚", "<Plug>GoVSMUp", desc = "Move up" },
        { mode = { "x" }, "¬", "<Plug>GoVSMRight", desc = "move right" },
      }
    end
  }
}
