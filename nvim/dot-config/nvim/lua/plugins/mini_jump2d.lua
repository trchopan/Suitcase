return {
  "nvim-mini/mini.jump2d",
  version = false,
  keys = {
    {
      "f",
      function()
        local jump2d = require("mini.jump2d")
        jump2d.start(jump2d.builtin_opts.word_start)
      end,
      mode = { "n", "x", "o" },
      desc = "Jump to word",
    },
  },
  config = function()
    require("mini.jump2d").setup({
      labels = "arstneiodhclmfuvbwkjxzqpg",
      view = {
        -- Whether to dim lines with at least one jump spot
        dim = true,

        -- How many steps ahead to show. Set to big number to show all steps.
        n_steps_ahead = 2,
      },
    })

    -- 🎨 Catppuccin colors
    local palette = require("catppuccin.palettes").get_palette()

    vim.api.nvim_set_hl(0, "MiniJump2dSpot", {
      fg = palette.flamingo,
      bold = true,
    })

    vim.api.nvim_set_hl(0, "MiniJump2dSpotAhead", {
      fg = palette.blue,
    })

    vim.api.nvim_set_hl(0, "MiniJump2dSpotUnique", {
      fg = palette.pink,
      bold = true,
    })
  end,
}
