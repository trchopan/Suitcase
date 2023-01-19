local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

configs.setup({
    ensure_installed = {
        "c",
        "typescript",
        "javascript",
        "haskell",
        "rust",
        "go",
        "python",
        "bash",
        "json",
        "lua",
        "dart",
        "html",
        "css",
        "scss",
        "vue",
        "vim",
        "yaml",
        "toml",
    },
    sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
    ignore_install = { "" }, -- List of parsers to ignore installing
    autopairs = {
        enable = true,
    },
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = { "" }, -- list of language that will be disabled
        additional_vim_regex_highlighting = true,
    },
    indent = { enable = true },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    }
})
