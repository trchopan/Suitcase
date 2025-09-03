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

return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      inline = {
        adapter = {
          name = "gemini",
          model = "gemini-2.5-flash",
          -- name = "openai",
          -- model = "gpt-5",
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
          -- name = "openai",
          -- model = "gpt-5",
        },
        keymaps = {
          send = {
            modes = { n = "<leader><CR>" },
          },
        },
      },
    },
    adapters = {
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          env = {
            api_key = "cmd:secret-openai personal",
          },
        })
      end,
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          env = {
            api_key = "cmd:secret-genai",
          },
        })
      end,
    },
    prompt_library = {
      ["Improve code"] = {
        strategy = "chat",
        description = "Improve the select code",
        opts = {
          modes = { "v" },
          short_name = "improve_code",
          auto_submit = true,
          stop_context_insertion = true,
          ignore_system_prompt = false,
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
          ignore_system_prompt = false,
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
          modes = { "v" },
          short_name = "fix_error",
          auto_submit = false,
          stop_context_insertion = true,
          ignore_system_prompt = true,
        },
        prompts = {
          {
            role = "user",
            content = function(context)
              return "#{buffer}\n\nI have the following error:\n\n```" .. context.filetype .. "\n\n\n```\n\nHelp me fix it."
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
      "<leader>aa",
      "<cmd>CodeCompanionChat Add<CR>",
      desc = "Add Selected Text to Chat Buffer",
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
