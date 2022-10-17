local ok, session = pcall(require, "auto-session")
if not ok then
    return
end

session.setup {
    log_level = "error",
    auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
}

require('session-lens').setup {
    path_display = { 'shorten' },
}

local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap
k("n", "<leader>ss", "<Cmd>Telescope session-lens search_session<CR>", opt)
