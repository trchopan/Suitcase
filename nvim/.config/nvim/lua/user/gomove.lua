local status_ok, gomove = pcall(require, "gomove")
if not status_ok then
    return
end

gomove.setup {
    -- whether or not to map default key bindings, (true/false)
    map_defaults = true,
    -- whether or not to reindent lines moved vertically (true/false)
    reindent = true,
    -- whether or not to undojoin same direction moves (true/false)
    undojoin = true,
    -- whether to not to move past end column when moving blocks horizontally, (true/false)
    move_past_end_col = false,
}

local map = vim.api.nvim_set_keymap

map("n", "˙", "<Plug>GoNSMLeft", {})
map("n", "∆", "<Plug>GoNSMDown", {})
map("n", "˚", "<Plug>GoNSMUp", {})
map("n", "¬", "<Plug>GoNSMRight", {})

map("x", "˙", "<Plug>GoVSMLeft", {})
map("x", "∆", "<Plug>GoVSMDown", {})
map("x", "˚", "<Plug>GoVSMUp", {})
map("x", "¬", "<Plug>GoVSMRight", {})

map("n", "<C-h>", "<Plug>GoNSDLeft", {})
map("n", "<C-j>", "<Plug>GoNSDDown", {})
map("n", "<C-k>", "<Plug>GoNSDUp", {})
map("n", "<C-l>", "<Plug>GoNSDRight", {})

map("x", "<C-h>", "<Plug>GoVSDLeft", {})
map("x", "<C-j>", "<Plug>GoVSDDown", {})
map("x", "<C-k>", "<Plug>GoVSDUp", {})
map("x", "<C-l>", "<Plug>GoVSDRight", {})
