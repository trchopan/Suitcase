return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      treesitter
        .install({
          "json",
          "javascript",
          "typescript",
          "tsx",
          "yaml",
          "html",
          "css",
          "prisma",
          "markdown",
          "markdown_inline",
          "svelte",
          "graphql",
          "bash",
          "lua",
          "vim",
          "dockerfile",
          "gitignore",
          "query",
          "vimdoc",
          "c",
          "elixir",
          "fish",
          "python",
          "go",
          "rust",
          "php",
        })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "c",
          "css",
          "dockerfile",
          "elixir",
          "eelixir",
          "fish",
          "gitignore",
          "go",
          "graphql",
          "heex",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "php",
          "prisma",
          "python",
          "rust",
          "svelte",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        callback = function()
          vim.treesitter.start()
        end,
      })

      -- use bash parser for zsh files only (fish has its own parser)
      vim.treesitter.language.register("bash", "zsh")
    end,
  },
}
