local neo_tree_commands = require("mylua.neo-tree-commands")

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    keys = function()
      return {
        { "<leader>\\", "<cmd>Neotree toggle<cr>", desc = "Toggle Neotree" },
        { "`h", "<cmd>Neotree focus reveal<cr>", desc = "Show file in Neotree" },
      }
    end,
    opts = {
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["z"] = "noop",
          ["P"] = "paste_from_clipboard",
          ["p"] = function(state)
            local node = state.tree:get_node()
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end,
          ["/"] = "noop", -- Search by f instead
          ["f"] = function(_)
            require("hop").hint_lines_skip_whitespace()
          end,
          -- ["g/"] = "fuzzy_finder",
          ["<leader>P"] = function(state)
            local node = state.tree:get_node()
            require("telescope.builtin").live_grep({
              prompt_title = "Search in " .. node.path,
              cwd = node.path,
            })
          end,
          ["<leader>p"] = function(state)
            local node = state.tree:get_node()
            if node and node.type == "directory" then
              require("telescope.builtin").find_files({
                prompt_title = "Find files in " .. node.path,
                search_dirs = { node.path },
              })
            else
              vim.notify("Cursor is not on a directory.", vim.log.levels.WARN)
            end
          end,
          ["Y"] = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local result = vim.fn.fnamemodify(filepath, ":.")
            vim.fn.setreg("*", result)
          end,
          ["O"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with System Application",
          },
          ["<leader>ya"] = "copy_path_to_right_buffer",
          ["<leader>ys"] = "copy_file_content_to_scratch",
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = false, -- This will find and focus the file in the active buffer every time
          -- the current file is changed while the tree is open.
          leave_dirs_open = true, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        commands = {
          -- Use functions from the separate module
          copy_path_to_right_buffer = neo_tree_commands.copy_path_to_right_buffer,
          copy_file_content_to_clipboard = neo_tree_commands.copy_file_content_to_clipboard,
          copy_file_content_to_scratch = neo_tree_commands.copy_file_content_to_scratch,
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
  },
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "notify" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "terminal", "quickfix" },
          },
        },
      })
    end,
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
  },
}
