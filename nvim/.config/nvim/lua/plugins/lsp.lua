return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      autoformat = false,
    },
    keys = {
      { "<leader>rr", "<cmd>LspRestart<cr>", desc = "Restart LSP" },
    },
    setup = {
      ruff_lsp = function()
        require("lazyvim.util").on_attach(function(client, _)
          if client.name == "ruff_lsp" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end
        end)
      end,
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- python
        "ruff",
        "ruff-lsp",
        "pyright",
        "black",

        -- javascript/typescript
        "prettier",
        "typescript-language-server",

        -- rust
        "rust-analyzer",

        -- go
        -- handled by lazy.lua
      },
    },
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      -- local mason_registry = require("mason-registry")
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      -- local code_actions = null_ls.builtins.code_actions

      null_ls.setup({
        -- debug = true, -- Turn on debug for :NullLsLog
        debug = false,
        -- diagnostics_format = "#{m} #{s}[#{c}]",
        sources = {
          formatting.prettier,
          formatting.brittany,
          formatting.cabal_fmt,
          formatting.black,
          diagnostics.ruff,
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    opts = {
      mapping = {
        ["<CR>"] = require("cmp").mapping({
          i = function(fallback)
            if require("cmp").visible() and require("cmp").get_active_entry() then
              require("cmp").confirm({ behavior = require("cmp").ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = require("cmp").mapping.confirm({ select = true }),
          c = require("cmp").mapping.confirm({ behavior = require("cmp").ConfirmBehavior.Replace, select = true }),
        }),
      },
      preselect = require('cmp').PreselectMode.None,
      completion = {
        completeopt = "noselect",
      }
    },
  },
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },
}
