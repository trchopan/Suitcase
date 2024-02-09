return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    opts = {
      api_key_cmd = "secret-openai",
      actions_paths = {
        vim.fn.expand("$HOME/.config/nvim/chatgpt-actions.json"),
      },
      openai_params = {
        model = "gpt-4-1106-preview",
      },
      openai_edit_params = {
        model = "gpt-4",
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        mode = { "n" },
        "<leader>pp",
        function()
          require("chatgpt").openChat()
        end,
        desc = "ChatGPT Open Chat",
      },
      {
        mode = { "v" },
        "<leader>pv",
        function()
          require("chatgpt").edit_with_instructions()
        end,
        desc = "ChatGPT Code with instruction",
      },
      {
        mode = { "v" },
        "<leader>pg",
        "<cmd>ChatGPTRun grammar_correction<cr>",
        desc = "ChatGPT Grammar Correction",
      },
      {
        mode = { "v" },
        "<leader>pc",
        "<cmd>ChatGPTRun complete_code<cr>",
        desc = "ChatGPT Complete Code",
      },
    },
  },
}
