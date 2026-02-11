return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufReadPost",
  opts = {
    filetypes = {
      markdown = true,
      help = true,
      yaml = true,
    },
    panel = {
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = {
        position = "bottom",
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<C-l>",
        accept_word = false,
        accept_line = false,
        next = "<C-j>",
        prev = "<C-k>",
        dismiss = "<C-c>",
      },
    },
  },
}
