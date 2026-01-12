local M = {}

-- Function to execute mix usage_rules.search_docs command and return the output
-- @param search_term - The term to search for (required)
-- @param packages - The packages to filter by (optional, can be a string or table of strings)
-- @return output - The command output as a string
-- @return success - Boolean indicating if the command succeeded
-- @return command - The executed command string (useful for error messages)
function M.exec_search_docs(search_term, packages)
  -- Validate input
  if not search_term or search_term == "" then
    return "Error: Search term is required", false, ""
  end

  -- Build the command
  local command = 'mix usage_rules.search_docs "' .. search_term .. '"'

  -- Add package filter(s) if provided
  if packages then
    -- Handle both string and table inputs
    if type(packages) == "string" then
      -- Single package as string
      if packages ~= "" then
        command = command .. " -p " .. packages
      end
    elseif type(packages) == "table" then
      -- Multiple packages as table
      for _, pkg in ipairs(packages) do
        if pkg and pkg ~= "" then
          command = command .. " -p " .. pkg
        end
      end
    end
  end

  -- Create a temporary file to store output
  local temp_file = os.tmpname()

  -- Execute the command and redirect output to the temporary file
  local full_command = command .. " > " .. temp_file .. " 2>&1"
  local exit_code = os.execute(full_command)

  -- Read the output from the temporary file
  local file = io.open(temp_file, "r")
  if not file then
    return "Error: Could not read output", false, command
  end

  local output = file:read("*all")
  file:close()

  -- Strip ANSI color codes
  output = output:gsub("\27%[[0-9;]*m", "")

  -- Remove the temporary file
  os.remove(temp_file)

  -- Check if the command was successful
  local success = exit_code == 0

  if success and (not output or output == "") then
    output = "No results found for: " .. search_term
  end

  return output, success, command
end

-- Function to search docs using mix usage_rules.search_docs and print the result
-- @param search_term - The term to search for (required)
-- @param packages - The packages to filter by (optional, can be a string or table of strings)
function M.search_docs(search_term, packages)
  local output, success, command = M.exec_search_docs(search_term, packages)

  if success then
    print(output)
  else
    print("Error executing command: " .. command)
    print(output)
  end
end

-- Function to create a temporary buffer and display content
-- @param title - Title for the buffer
-- @param content - Content to display in the buffer
-- @param filetype - Optional filetype for syntax highlighting (default: markdown)
function M.show_in_buffer(title, content, filetype)
  -- Create a new buffer
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- Set buffer name
  vim.api.nvim_buf_set_name(bufnr, title)

  -- Split content into lines, preserving blank lines
  local lines = vim.split(content, "\n", { plain = true, trimempty = false })

  -- Set buffer lines
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Open buffer in a new window (split)
  vim.cmd("botright split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)

  -- Set options for the buffer
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

  -- Set filetype if provided
  if filetype then
    vim.api.nvim_set_option_value("filetype", filetype, { buf = bufnr })
  else
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
  end

  -- Add key mapping to close the buffer with 'q'
  vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":q<CR>", { noremap = true, silent = true })

  return bufnr
end

-- Function to search docs and show results in a buffer
-- @param search_term - The term to search for (required)
-- @param packages - The packages to filter by (optional, can be a string or table of strings)
function M.search_docs_buffer(search_term, packages)
  local output, success, command = M.exec_search_docs(search_term, packages)

  -- Create the buffer title
  local title = "[Mix Usage Rules] " .. search_term
  if packages then
    if type(packages) == "string" then
      title = title .. " (-p " .. packages .. ")"
    elseif type(packages) == "table" and #packages > 0 then
      title = title .. " (-p " .. table.concat(packages, ",") .. ")"
    end
  end

  if success then
    M.show_in_buffer(title, output, "markdown")
  else
    local error_title = "[Mix Usage Rules Error]"
    local error_msg = "Error executing command: " .. command .. "\n\n" .. output
    M.show_in_buffer(error_title, error_msg, "markdown")
  end
end

-- Example usage:
-- Print output to console:
-- require('mylua.mix_usage_rules').search_docs("schema", "ecto")
-- require('mylua.mix_usage_rules').search_docs("schema", {"ecto", "phoenix"})
--
-- Show output in buffer:
-- require('mylua.mix_usage_rules').search_docs_buffer("schema", "ecto")
-- require('mylua.mix_usage_rules').search_docs_buffer("schema", {"ecto", "phoenix"})

return M
