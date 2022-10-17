local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

local tree_view = require("nvim-tree.view")
local default_open = tree_view.open
local default_close = tree_view.close

tree_view.open = function()
    require("bufferline.api").set_offset(30 + 1, "")
    default_open()
end

tree_view.close = function()
    require("bufferline.api").set_offset(0)
    default_close()
end

nvim_tree.setup({
    renderer = {
        icons = {
            git_placement = "after",
            glyphs = {
                default = "",
                symlink = "",
                git = {
                    unstaged = "",
                    staged = "ﰷ",
                    unmerged = "",
                    renamed = "",
                    deleted = "ﯰ",
                    untracked = "",
                    ignored = "",
                },
                folder = {
                    arrow_closed = "",
                    arrow_open = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                },
            }
        }
    },
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    ignore_ft_on_setup = {
        "startify",
        "dashboard",
        "alpha",
    },
    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = true,
    diagnostics = {
        enable = true,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        },
    },
    update_focused_file = {
        enable = true,
        update_cwd = false,
        ignore_list = {},
    },
    system_open = {
        cmd = nil,
        args = {},
    },
    filters = {
        dotfiles = true,
        custom = { ".DS_Store", ".cache" },
    },
    git = {
        enable = true,
        ignore = true,
        timeout = 500,
    },
    view = {
        width = 30,
        hide_root_folder = false,
        side = "left",
        preserve_window_proportions = true,
        number = false,
        relativenumber = false,
        signcolumn = "yes",
        mappings = {
            custom_only = false,
            list = {
                { key = { "l", "<CR>" }, action = "edit" },
                { key = "h", action = "close_node" },
                { key = "p", action = "parent_node" },
                { key = "s", action = "vsplit" },
                { key = "o", action = "system_open" },
                { key = "P", action = "paste" },
                { key = "<Space>", action = "" },
            },
        },
    },
    trash = {
        cmd = "trash",
        require_confirm = true,
    },
})

local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "\\\\", "<Cmd>NvimTreeToggle<CR>", opt)
k("n", "`h", "<Cmd>NvimTreeFocus<CR>", opt)
