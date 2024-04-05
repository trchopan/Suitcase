return {
  "tpope/vim-dadbod",
  dependencies = {
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
  },
  keys = {
    { "<leader>d", "<cmd>DBUIToggle<cr>", { desc = "Toggle DBUI" } },
    { "`h", "<cmd>Neotree focus reveal<cr>", { desc = "Show file in Neotree" } },
  },
}
