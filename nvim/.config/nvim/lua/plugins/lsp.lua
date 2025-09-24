local _border = "single"

local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
  return hover({
    max_width = 120,
    border = _border,
  })
end

vim.g.autoformat = false

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.livemd",
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    keys = {
      { "<leader>rr", "<cmd>LspRestart<cr>", desc = "Restart LSP" },
    },
    opts = {
      inlay_hints = { enabled = false },
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
  {
    "mason-org/mason.nvim",
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

        -- elixir
        -- "nextls"
      },
      ui = {
        border = "single",
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
    "folke/trouble.nvim",
    keys = {
      { "<leader>cs", false },
    },
  },
}
