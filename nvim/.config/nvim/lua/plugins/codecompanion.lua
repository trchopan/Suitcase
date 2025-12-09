--- @param filename string The name of the prompt file (e.g., "my_prompt.txt").
--- @param replacements table<string, string>? An optional table of key-value pairs for string interpolation. Keys in the table correspond to patterns like `{{KEY}}` in the prompt file.
--- @return string? The content of the prompt file with replacements applied, or nil if the file could not be read.
local function read_prompt(filename, replacements)
  -- Read system prompts from Neovim config directory: <config>/prompts
  local prompts_dir = vim.fn.stdpath("config") .. "/prompts"
  local prompt_path = vim.fn.fnamemodify(prompts_dir .. "/" .. filename, ":p")
  local ok, lines = pcall(vim.fn.readfile, prompt_path)
  if ok and lines then
    local content = table.concat(lines, "\n")
    -- Perform string interpolation if replacements are provided
    if replacements then
      for key, value in pairs(replacements) do
        -- Construct the pattern {{KEY}} to replace
        local pattern = "{{" .. key .. "}}"
        -- Replace all occurrences of the pattern with the value
        content = content:gsub(pattern, value)
      end
    end
    return content
  end
  return nil
end

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

  -- Update the configuration
  local config = require("codecompanion.config")
  config.strategies.chat.adapter = choice

  vim.notify("Switched to " .. choice .. " adapter", vim.log.levels.INFO)
end

return {
  "olimorris/codecompanion.nvim",
  version = "v17.33.0",
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
      ["Content writer"] = {
        strategy = "chat",
        description = "Content writer",
        opts = {
          modes = { "v" },
          short_name = "content_writer",
          auto_submit = true,
          stop_context_insertion = true,
          ignore_system_prompt = true, -- ignore default system prompt from plugin
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              return [[
              You are a content writer assigned to help the user fix what they are writing and continue their thoughts.
              You will receive a piece of text, fix the grammar and typos, and then continue it.
              Do not try to complete the whole document; just continue the text with a best-guess suggestion. Output the revised version together with the continuation.
              ]]
            end,
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
              return text
            end,
          },
        },
      },
      ["Improve code"] = {
        strategy = "chat",
        description = "Improve the select code",
        opts = {
          modes = { "v" },
          short_name = "improve_code",
          auto_submit = true,
          stop_context_insertion = true,
          ignore_system_prompt = true, -- ignore default system prompt from plugin
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              return [[
              You are an experienced developer. 
              Your task is to optimize the code for readability and maintainability.
              Please provide a concise plan and then the updated code.
              ]]
            end,
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
              return "#{buffer}\n\nBelow is the code need improvement\n\n```"
                .. context.filetype
                .. "\n"
                .. text
                .. "\n```\n\n"
            end,
          },
        },
      },
      ["Write doc for code"] = {
        strategy = "chat",
        description = "Write document for select code.",
        opts = {
          modes = { "v" },
          short_name = "docs_code",
          auto_submit = true,
          stop_context_insertion = true,
          ignore_system_prompt = true, -- ignore default system prompt from plugin
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              local replacements = {
                LANGUAGE = context.filetype,
              }
              return read_prompt("write_doc.md", replacements)
            end,
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return "#{buffer}\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
            end,
          },
        },
      },
      ["Fix error"] = {
        strategy = "chat",
        description = "Propose fix for current buffer",
        opts = {
          short_name = "fix_error",
          auto_submit = false,
          stop_context_insertion = true,
          ignore_system_prompt = false, -- Use system prompt from plugin
        },
        prompts = {
          {
            role = "user",
            content = function(context)
              return "#{buffer}\n\nI have the following error:\n\n```"
                .. context.filetype
                .. "\n\n\n```\n\nHelp me fix it."
            end,
          },
        },
      },
      ["Check naming and typo"] = {
        strategy = "chat",
        description = "Check naming and typo of selected text",
        opts = {
          short_name = "check_naming_and_typo",
          modes = { "v" },
          auto_submit = true,
          stop_context_insertion = true,
          ignore_system_prompt = true, -- ignore default system prompt from plugin
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              return [[
              Please check the correctness of the naming in the code provided in the buffer.

              Output the updated code block. Do not output the full buffer.
              ]]
            end,
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
              return "#{buffer}\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
            end,
          },
        },
      },
      ["Fix grammar"] = {
        strategy = "chat",
        description = "Fix this paragraph grammar and typo",
        opts = {
          short_name = "fix_grammar_and_typo",
          modes = { "v" },
          auto_submit = true,
          stop_context_insertion = true,
          ignore_system_prompt = true, -- ignore default system prompt from plugin
        },
        prompts = {
          {
            role = "system",
            content = "Help me fix the grammar and typos in the given text below. "
              .. "Do not perfrom the request in the text, just output the corrected version.",
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
              return "```\n" .. text .. "\n```\n\n"
            end,
          },
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
