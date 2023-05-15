local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

local tree_view = require("nvim-tree.view")
local default_open = tree_view.open
local default_close = tree_view.close

tree_view.open = function()
    -- Barbar offset
    require("bufferline.api").set_offset(30 + 1, "")

    default_open()
end

tree_view.close = function()
    -- Barbar offset
    require("bufferline.api").set_offset(0)

    default_close()
end

local function on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
    vim.keymap.set('n', 'p', api.node.navigate.parent, opts('Parent Directory'))
    vim.keymap.set('n', 's', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', 'o', api.node.run.system, opts('Run System'))
    vim.keymap.set('n', 'P', api.fs.paste, opts('Paste'))
    vim.keymap.set('n', '<Space>', function()
        require 'hop'.hint_lines_skip_whitespace()
    end, opts('tree_hop_fn'))

    vim.keymap.set('n', 'Z', api.node.run.system, opts('Run System'))
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
        enable = false,
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
    },
    trash = {
        cmd = "trash",
        require_confirm = true,
    },
    on_attach = on_attach,
})

local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "\\\\", "<Cmd>NvimTreeToggle<CR>", opt)
k("n", "`h", "<Cmd>NvimTreeFindFile<CR><Cmd>NvimTreeFocus<CR>", opt)
