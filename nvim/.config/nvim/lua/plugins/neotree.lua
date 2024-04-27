return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    "s1n7ax/nvim-window-picker",
  },
  keys = function()
    return {
      { "<leader>\\", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neotree" } },
      { "`h", "<cmd>Neotree focus reveal<cr>", { desc = "Show file in Neotree" } },
    }
  end,
  opts = {
    event_handlers = {
      {
        event = "neo_tree_popup_input_ready",
        ---@param input NuiInput
        handler = function(input)
          -- enter input popup with normal mode by default.
          vim.cmd("stopinsert")
        end,
      },
    },
    window = {
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["P"] = "paste_from_clipboard",
        ["p"] = function(state)
          local node = state.tree:get_node()
          require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
        end,
        ["f"] = function(_)
          require("hop").hint_lines_skip_whitespace()
        end,
        ["/"] = "noop",
        ["g/"] = "fuzzy_finder",
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,         -- This will find and focus the file in the active buffer every time
        --                         -- the current file is changed while the tree is open.
        leave_dirs_open = true, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
      },
    },
    default_component_configs = {
      diagnostics = {
        symbols = {
          hint = "",
          info = "",
          warn = "",
          error = "",
          -- hint = "H",
          -- info = "I",
          -- warn = "!",
          -- error = "X",
        },
        highlights = {
          hint = "DiagnosticSignHint",
          info = "DiagnosticSignInfo",
          warn = "DiagnosticSignWarn",
          error = "DiagnosticSignError",
        },
      },
      git_status = {
        symbols = {
          -- Change type
          added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
          modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
          deleted = "✖", -- this can only be used in the git_status source
          renamed = "󰁕", -- this can only be used in the git_status source
          -- Status type
          untracked = "",
          ignored = "",
          unstaged = "",
          staged = "",
          conflict = "",
        },
      },
    },
  },
}
