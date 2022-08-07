local status_ok, hop = pcall(require, "hop")
if not status_ok then
  return
end

hop.setup({
  -- keys = "etovxqpdygfblzhckisuran",
  quit_key = "<Space>",
})

local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "<Space>", ":HopWord<CR>", opt)
