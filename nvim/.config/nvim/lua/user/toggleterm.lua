local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

toggleterm.setup({
  open_mapping = [[<c-\>]],
  direction = 'horizontal',
})

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  local k = vim.api.nvim_buf_set_keymap
  k(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  k(0, 't', 'jk', [[<C-\><C-n>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
