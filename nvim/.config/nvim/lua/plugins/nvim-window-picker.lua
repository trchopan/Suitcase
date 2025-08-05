return {
  "s1n7ax/nvim-window-picker",
  keys = {
    {
      mode = { "n" },
      "gwd",
      function()
        -- Step 1: Create a mark at the current cursor position
        vim.cmd("mark M")

        -- Step 2: Go to the definition at the current cursor
        vim.lsp.buf.definition()

        -- Step 3: Use window-picker to select another window
        local picker = require("window-picker")
        local picked_window = picker.pick_window()
        if picked_window then
          vim.api.nvim_set_current_win(picked_window)
        else
          -- Open a new split window if no window is selected
          vim.cmd("vsplit")
          local new_window = vim.api.nvim_get_current_win()
          vim.api.nvim_set_current_win(new_window)
        end

        -- Step 4: Go to the saved mark
        vim.cmd("normal! `M")
      end,
      desc = "Goto Definition in a window picker",
    },
  },
}
