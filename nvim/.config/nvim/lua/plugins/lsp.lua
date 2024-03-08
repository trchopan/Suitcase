local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = _border,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = _border,
})

vim.g.autoformat = false

return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "<leader>rr", "<cmd>LspRestart<cr>", desc = "Restart LSP" },
    },
    setup = {
      -- ruff_lsp = function()
      --   require("lazyvim.util").on_attach(function(client, _)
      --     if client.name == "ruff_lsp" then
      --       -- Disable hover in favor of Pyright
      --       client.server_capabilities.hoverProvider = false
      --       client.server_capabilities.diagnostics = false
      --     end
      --   end)
      -- end,
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- python
        -- "ruff",
        -- "ruff-lsp",
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
    "nvimtools/none-ls.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.prettier,
        nls.builtins.formatting.black,
        -- nls.builtins.diagnostics.ruff,
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
      preselect = require("cmp").PreselectMode.None,
      completion = {
        completeopt = "noselect",
      },
      window = {
        documentation = require("cmp").config.window.bordered(),
      },
    },
  },
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },
}
