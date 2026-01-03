return {
  -- Local plugin; no repository needed
  dir = vim.fn.stdpath("config"),
  name = "ai_utils",
  config = function()
    require("mylua.ai_utils").setup({
      model = "gpt-5-nano",
    })
  end,
}

