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

local ai_mode = get_ai_mode()
local configured_strategies = {}

if ai_mode == "line" then
  configured_strategies = {
    inline = {
      adapter = {
        name = "openai_line",
        model = "gpt-4.1",
      },
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
      adapter = {
        name = "openai_line",
        model = "gpt-4.1",
      },
      keymaps = {
        send = {
          modes = { n = "<leader><CR>" },
        },
      },
    },
  }
else
  configured_strategies = {
    inline = {
      adapter = {
        name = "gemini",
        model = "gemini-2.5-flash",
      },
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
      adapter = {
        name = "gemini",
        model = "gemini-2.5-flash",
      },
      keymaps = {
        send = {
          modes = { n = "<leader><CR>" },
        },
      },
    },
  }
end

return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = configured_strategies,
    adapters = {
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
    prompt_library = {
      ["Content writer"] = {
        strategy = "chat",
        description = "Content writer",
        opts = {
          modes = { "n" },
          short_name = "content_writer",
          auto_submit = false,
          stop_context_insertion = true,
          ignore_system_prompt = true, -- ignore default system prompt from plugin
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              return read_prompt("content_writer.md", {})
            end,
          },
          {
            role = "user",
            content = "",
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
              return read_prompt("improve_code.md", {})
            end,
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
              return "```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
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

              return "```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
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
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
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
      "<leader>aa",
      "<cmd>CodeCompanionChat Add<CR>",
      desc = "Add Selected Text to Chat Buffer",
    },
    {
      mode = { "n" },
      "<leader>ar",
      "<cmd>CodeCompanion /fix_error<CR>",
      desc = "Open Fix Error Code Assistant",
    },
    {
      mode = { "n" },
      "<leader>at",
      "<cmd>CodeCompanion /content_writer<CR>",
      desc = "Open Content Writer Assistant",
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
