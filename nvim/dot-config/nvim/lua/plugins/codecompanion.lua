local function get_ai_mode()
  local ai_mode_file = vim.fn.expand("~/.ai_mode")
  local ok, lines = pcall(vim.fn.readfile, ai_mode_file)
  if ok and lines and #lines > 0 then
    return vim.trim(lines[1])
  end
  return nil
end

local function get_current_adapter()
  local ai_mode = get_ai_mode()
  if ai_mode == "openai_line" then
    return { name = "openai_line", model = "gpt-5-nano" }
  elseif ai_mode == "gemini" then
    return { name = "gemini", model = "gemini-2.5-flash" }
  else
    -- Default to openai if no mode is set or it's 'openai'
    return { name = "openai", model = "gpt-5-nano" }
  end
end

-- Function to set AI mode
local function set_ai_mode(choice)
  if not choice then
    return
  end

  local ai_mode_file = vim.fn.expand("~/.ai_mode")
  local ok, err = pcall(vim.fn.writefile, { choice }, ai_mode_file)
  if not ok then
    vim.notify("Failed to write AI mode: " .. err, vim.log.levels.ERROR)
    return false
  end

  vim.notify("Switched to " .. choice .. " adapter", vim.log.levels.INFO)
end

return {
  "olimorris/codecompanion.nvim",
  -- version = "v17.33.0",
  opts = {
    strategies = {
      inline = {
        adapter = get_current_adapter(),
        keymaps = {
          accept_change = {
            modes = { n = "<leader>at" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "<leader>ar" },
            description = "Reject the suggested change",
          },
        },
      },
      chat = {
        adapter = get_current_adapter(),
        keymaps = {
          send = {
            modes = { n = "<leader><CR>" },
          },
        },
        opts = {
          undolevels = 200,
        },
      },
    },
    display = {
      chat = {
        window = {
          layout = "vertical",
          position = "right",
        },
      },
    },
    adapters = {
      http = {
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = "cmd:secret-key openai personal",
            },
          })
        end,
        openai_line = function()
          return require("codecompanion.adapters").extend("openai", {
            name = "openai_line",
            url = "https://openai-proxy.linecorp.com/v1/chat/completions",
            env = {
              api_key = "cmd:secret-key openai line",
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = "cmd:secret-key gemini personal",
            },
          })
        end,
        tavily = function()
          return require("codecompanion.adapters").extend("tavily", {
            env = {
              api_key = "cmd:secret-key tavily personal",
            },
          })
        end,
      },
    },
    prompt_library = {
      markdown = {
        dirs = {
          vim.fn.stdpath("config") .. "/prompts",
        },
      },
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true,
        },
      },
      history = {
        enabled = true,
        opts = {
          ---When chat is cleared with `gx` delete the chat from history
          delete_on_clearing_chat = false,
          expiration_days = 7,
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/mcphub.nvim",
    "ravitemer/codecompanion-history.nvim",
  },
  keys = {
    {
      mode = { "n" },
      "<leader>aS",
      function()
        vim.ui.select({ "openai", "openai_line", "gemini" }, {
          prompt = "Select AI mode:",
        }, function(choice)
          set_ai_mode(choice)
        end)
      end,
      desc = "Select AI Mode",
    },
    {
      mode = { "v" },
      "<leader>ai",
      "<cmd>CodeCompanion<CR>",
      desc = "Open Inline Assistant",
    },
    {
      mode = { "v" },
      "<leader>ae",
      "<cmd>CodeCompanion /improve_code<CR>",
      desc = "Open Improve Code Assistant",
    },
    {
      mode = { "v" },
      "<leader>ad",
      "<cmd>CodeCompanion /docs_code<CR>",
      desc = "Open Write Docs Code Assistant",
    },
    {
      mode = { "v" },
      "<leader>ag",
      "<cmd>CodeCompanion /fix_grammar_and_typo<CR>",
      desc = "Open Fix grammar and typos Code Assistant",
    },
    {
      mode = { "v" },
      "<leader>ah",
      "<cmd>CodeCompanion /check_naming_and_typo<CR>",
      desc = "Open Check code naming and typo Code Assistant",
    },
    {
      mode = { "v" },
      "<leader>aa",
      "<cmd>CodeCompanionChat Add<CR>",
      desc = "Add Selected Text to Chat Buffer",
    },
    {
      mode = { "v" },
      "<leader>at",
      "<cmd>CodeCompanion /content_writer<CR>",
      desc = "Open Content Writer Assistant",
    },
    {
      mode = { "n" },
      "<leader>as",
      "<cmd>CodeCompanion /ai_patch<CR>",
      desc = "Open Assistant to apply an AI response as a patch job",
    },
    {
      mode = { "n" },
      "<leader>ar",
      "<cmd>CodeCompanion /fix_error<CR>",
      desc = "Open Fix Error Code Assistant",
    },
    {
      mode = { "n" },
      "<leader>an",
      "<cmd>CodeCompanionChat<CR>",
      desc = "New Chat Buffer",
    },
    {
      mode = { "n" },
      "<leader>ac",
      "<cmd>CodeCompanionChat Toggle<CR>",
      desc = "Toggle Chat Buffer",
    },
    {
      mode = { "n" },
      "<leader>aA",
      "<cmd>CodeCompanionCmd<CR>",
      desc = "Generate Command in Command-line",
    },
    {
      mode = { "n" },
      "<leader>ap",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Open Action Palette",
    },
    -- {
    --   mode = { "n" },
    --   "<leader>at",
    --   "<cmd>CodeCompanionChat Toggle<CR>",
    --   desc = "Toggle Chat Buffer",
    -- },
  },
}
