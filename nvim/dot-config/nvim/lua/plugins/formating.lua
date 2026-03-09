return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")
    local function has_biome_config(_, ctx)
      return vim.fs.find("biome.json", { upward = true, path = ctx.dirname })[1] ~= nil
    end

    conform.setup({
      formatters_by_ft = {
        vue = { "biome", "prettier", stop_after_first = true },
        javascript = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        svelte = { "prettier" },
        css = { "biome", "prettier", stop_after_first = true },
        html = { "prettier" },
        json = { "biome", "prettier", stop_after_first = true },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
      },
      formatters = {
        biome = {
          condition = has_biome_config,
        },
      },
      format_on_save = nil,
    })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
