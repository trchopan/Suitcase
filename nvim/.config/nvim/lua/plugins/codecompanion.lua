return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      inline = {
        keymaps = {
          accept_change = {
            modes = { n = "<leader>at" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "<leader>ar" },
            description = "Reject the suggested change",
          },
        },
      },
    },
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = "cmd:secret-openai",
          },
        })
      end,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    {
      mode = { "v" },
      "<leader>ai",
      "<cmd>CodeCompanion<CR>",
      desc = "Open Inline Assistant",
    },
    {
      mode = { "n" },
      "<leader>ac",
      "<cmd>CodeCompanionChat Toggle<CR>",
      desc = "Toggle Chat Buffer",
    },
    {
      mode = { "n" },
      "<leader>aa",
      "<cmd>CodeCompanionChat Add<CR>",
      desc = "Add Selected Text to Chat Buffer",
    },
    {
      mode = { "n" },
      "<leader>aA",
      "<cmd>CodeCompanionCmd<CR>",
      desc = "Generate Command in Command-line",
    },
    {
      mode = { "n" },
      "<leader>ap",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Open Action Palette",
    },
    -- {
    --   mode = { "n" },
    --   "<leader>at",
    --   "<cmd>CodeCompanionChat Toggle<CR>",
    --   desc = "Toggle Chat Buffer",
    -- },
  },
}
