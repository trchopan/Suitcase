return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      file_ignore_patterns = { "node_modules", "yarn.lock", "package%-lock.json", ".git/.*" },
      mappings = {
        i = {
          ["<C-n>"] = function(...)
            return require("telescope.actions").cycle_history_next(...)
          end,
          ["<C-p>"] = function(...)
            return require("telescope.actions").cycle_history_prev(...)
          end,
        },
      },
    },
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    require "telescope.multigrep".setup()
  end,
}
