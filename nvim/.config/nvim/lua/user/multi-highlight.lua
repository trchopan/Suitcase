local status_ok, multi_highlight = pcall(require, "multi-highlight")
if not status_ok then
    return
end

multi_highlight.setup({
    groups = { '#AEEE00', '#aa2222', '#2222aa', '#B08020', '#FFA020', '#22aa22', '#8888ff', '#22aa22' },
})


local opt = { noremap = true, silent = true }
local k = vim.api.nvim_set_keymap

k("n", "<leader>k", '<cmd>lua require("multi-highlight").toggle_highlight()<cr>', opt)
k("n", "<leader>K", '<cmd>lua require("multi-highlight").clear()<cr>', opt)
