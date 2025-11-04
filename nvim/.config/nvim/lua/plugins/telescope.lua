vim.keymap.set("n", "<leader>p", function()
  vim.ui.input({ prompt = "Find files in directory: " }, function(input)
    if input and #input > 0 then
      require("telescope.builtin").find_files({
        search_dirs = { input },
      })
    end
  end)
end, { desc = "Telescope find_files in directory" })

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
}
