local status_ok, mason = pcall(require, "mason")
if not status_ok then
    return
end
mason.setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "",
            package_uninstalled = "✗"
        }
    }
})
require("mason-lspconfig").setup()

require("mason-lspconfig").setup_handlers {
    -- default handler - setup with default settings
    function(server_name)
        local opts = {
            on_attach = require("user.lsp.handlers").on_attach,
            capabilities = require("user.lsp.handlers").capabilities,
        }

        if server_name == "jsonls" then
            local jsonls_opts = require("user.lsp.settings.jsonls")
            opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
        end

        if server_name == "sumneko_lua" then
            local sumneko_opts = require("user.lsp.settings.sumneko_lua")
            opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
        end

        require("lspconfig")[server_name].setup(opts)
    end,
}
