local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
    return
end
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local format = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
    sources = {
        format.prettier,
        format.brittany,
        format.cabal_fmt,
        format.black,
        diagnostics.mypy,
        diagnostics.ruff,
    },
})
