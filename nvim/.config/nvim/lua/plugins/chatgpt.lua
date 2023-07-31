return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "secret-openai",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    },
    keys = {
      {
        mode = { "v" },
        "<leader>pv",
        function()
          require("chatgpt").edit_with_instructions()
        end,
        desc = "ChatGPT Edit with instruction"
      },
      {
        mode = { "n" },
        "<leader>pp",
        function()
          require("chatgpt").openChat()
        end,
        desc = "ChatGPT Open Chat"
      },
      {
        mode = { "n" },
        "<leader>pc",
        function()
          require("chatgpt").complete_code()
        end,
        desc = "ChatGPT Complete Code"
      }
    }
  }
}
