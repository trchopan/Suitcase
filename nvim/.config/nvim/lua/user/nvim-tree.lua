local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

local function on_open()
  require("bufferline.state").set_offset(30 + 1, "")
end

local function on_close()
  require("bufferline.state").set_offset(0)
end

local tree_view = require("nvim-tree.view")
local default_open = tree_view.open
local default_close = tree_view.close

tree_view.open = function()
  on_open()
  default_open()
end

tree_view.close = function()
  on_close()
  default_close()
end

local config_status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
if not config_status_ok then
  return
end

local tree_cb = nvim_tree_config.nvim_tree_callback

nvim_tree.setup({
  renderer = {
    icons = {
      git_placement = "after",
      glyphs = {
        default = "",
        symlink = "",
        git = {
          unstaged = "",
          staged = "ﰷ",
          unmerged = "",
          renamed = "➜",
          deleted = "",
          untracked = "",
          ignored = "◌",
        },
        folder = {
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
    update_cwd = true,
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
    height = 30,
    hide_root_folder = false,
    side = "left",
    preserve_window_proportions = true,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    mappings = {
      custom_only = false,
      list = {
        { key = { "l", "<CR>", "o" }, cb = tree_cb("edit") },
        { key = "h", cb = tree_cb("close_node") },
        { key = "s", cb = tree_cb("vsplit") },
        { key = "o", cb = tree_cb("system_open") },
        { key = "p", cb = tree_cb("parent_node") },
        { key = "P", cb = tree_cb("paste") },
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
