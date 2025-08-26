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
          ignore_system_prompt = true,
          user_prompt = false,
        },
        prompts = {
          {
            role = "system",
            content = "You are an experienced developer. Your task is to enhance the readability and maintainability of the provided code. "
              .. "Focus on making it more understandable for other programmers and facilitating the creation of test cases. "
              .. "Please explain the changes you will make in a concise plan then provide the updated code as the output in code block format.",
          },
          {
            role = "user",
            content = function(context)
              local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

              return "I have the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
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
          ignore_system_prompt = true,
          user_prompt = false,
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              python_example = [[
```python
"""
Calculate the area of a rectangle.

Inputs:
- width (float): The width of the rectangle.
- height (float): The height of the rectangle.

Outputs:
- area (float): The calculated area of the rectangle.

Raises:
- If the width or height is less than or equal to zero.

Example:
    >>> calculate_area(5, 10)
    50
"""
def calculate_area(width, height):
    if width <= 0 or height <= 0:
        raise ValueError("Invalid input. Both width and height must be positive.")

    return width * height
```

```typescript
/**
 * Calculate the area of a rectangle.
 *
 * @param {number} width - The width of the rectangle. Must be a positive number.
 * @param {number} height - The height of the rectangle. Must be a positive number.
 * @returns {number} The area of the rectangle.
 * @throws {Error} Throws an error if either width or height is not positive.
 *
 * Example usage:
 * calculateArea(5, 10); // Returns 50
 */
function calculateArea(width: number, height: number): number {
    if (width <= 0 || height <= 0) {
        throw new Error("Invalid input. Both width and height must be positive.");
    }

    return width * height;
}

```go
// Calculate the area of a rectangle.
//
// Inputs:
// - width float64: The width of the rectangle.
// - height float64: The height of the rectangle.
//
// Outputs:
// - float64: The calculated area of the rectangle.
// - error: An error message if the calculation cannot be performed.
//
// Example:
//   CalculateArea(5, 10) // Returns 50
//
func CalculateArea(width, height float64) (float64, error) {
    if width <= 0 || height <= 0 {
        return 0, errors.New("Invalid input. Both width and height must be positive.")
    }
    return width * height, nil
}
```

```elixir
@doc """
Calculates the area of a rectangle.

## Parameters
- `width`: The width of the rectangle.
- `height`: The height of the rectangle.

## Returns
- `{:ok, area}`: The calculated area of the rectangle.
- `{:error, reason}`: The error tuple that might be returned if the calculation cannot be performed due to invalid input or other issues.

## Examples
    iex> calculate_area(5, 10)
    50
"""
def calculate_area(width, height) do
  if width <= 0 or height <= 0 do
    {:error, "Invalid input. Both width and height must be positive."}
  else
    {:ok, width * height}
  end
end
```
]]
              return "You are an expert in %s programming. Write a clear and concise documentation for given code. Here are some examples:\n\n"
                .. python_example
                .. "\n\nThe documentation should include a description of the code's purpose, its inputs, outputs, and any important details.\n"
                .. "Output only the document."
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
