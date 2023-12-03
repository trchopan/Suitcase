return {
  "simrat39/rust-tools.nvim",
  keys = {
    {
      "<C-t>rh",
      function()
        local isRustHint = vim.g.isRustHint
        if isRustHint == nil or isRustHint == true then
          require("rust-tools").inlay_hints.disable()
          vim.g.isRustHint = false
        else
          require("rust-tools").inlay_hints.enable()
          vim.g.isRustHint = true
        end
      end,
      desc = "Toggle rust-tools.nvim hint",
    },
  },
}
