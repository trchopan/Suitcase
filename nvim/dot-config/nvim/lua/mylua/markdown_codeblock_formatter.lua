local M = {}
local llm_buffer_locks = {}

local language_aliases = {
  js = "javascript",
  jsx = "javascriptreact",
  ts = "typescript",
  tsx = "typescriptreact",
  yml = "yaml",
  ex = "elixir",
  exs = "elixir",
  sh = "bash",
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function lock_buffer_for_llm(bufnr)
  if llm_buffer_locks[bufnr] then
    return nil, "LLM formatting already in progress for this buffer"
  end

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil, "Buffer is no longer valid"
  end

  local modifiable = vim.api.nvim_get_option_value("modifiable", { buf = bufnr })
  llm_buffer_locks[bufnr] = {
    modifiable = modifiable,
  }

  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
  return true, nil
end

local function unlock_buffer_for_llm(bufnr)
  local lock = llm_buffer_locks[bufnr]
  llm_buffer_locks[bufnr] = nil
  if not lock then
    return
  end

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_set_option_value("modifiable", lock.modifiable, { buf = bufnr })
end

local function split_lines(text)
  if text == "" then
    return {}
  end

  local lines = vim.split(text, "\n", { plain = true })
  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  return lines
end

local function normalize_language(lang)
  if not lang or lang == "" then
    return nil
  end

  local key = string.lower(lang)
  return language_aliases[key] or key
end

local function find_block_bounds(bufnr, cursor_line)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local open_line
  local lang

  for lnum = cursor_line, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    local detected_lang = line:match("^%s*```%s*([%w_+.-]+)%s*$")
    if detected_lang then
      open_line = lnum
      lang = detected_lang
      break
    end

    if line:match("^%s*```%s*$") then
      return nil, "No fenced code block under cursor"
    end
  end

  if not open_line then
    return nil, "No fenced code block under cursor"
  end

  local close_line
  for lnum = open_line + 1, line_count do
    local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
    if line:match("^%s*```%s*$") then
      close_line = lnum
      break
    end
  end

  if not close_line then
    return nil, "No closing fence found for current code block"
  end

  if cursor_line < open_line or cursor_line > close_line then
    return nil, "No fenced code block under cursor"
  end

  return {
    open_line = open_line,
    close_line = close_line,
    lang = lang,
  }
end

function M.format_code_block_under_cursor_with_llm()
  if vim.bo.filetype ~= "markdown" then
    notify("FormatCodeBlockLLM works in markdown buffers", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  local block, block_err = find_block_bounds(bufnr, cursor_line)
  if not block then
    notify(block_err, vim.log.levels.WARN)
    return
  end

  local normalized_lang = normalize_language(block.lang)
  if not normalized_lang then
    notify("Unable to detect code block language", vim.log.levels.WARN)
    return
  end

  local body_start = block.open_line + 1
  local body_end = block.close_line - 1
  local current_lines = vim.api.nvim_buf_get_lines(bufnr, body_start - 1, body_end, false)
  local input = table.concat(current_lines, "\n")

  local locked, lock_err = lock_buffer_for_llm(bufnr)
  if not locked then
    notify(lock_err, vim.log.levels.WARN)
    return
  end

  local ai_utils = require("mylua.ai_utils")
  notify("Formatting " .. normalized_lang .. " code block with LLM...")
  local ok, async_err = pcall(ai_utils.format_code_with_llm_async, normalized_lang, input, function(formatted_output, run_err)
    unlock_buffer_for_llm(bufnr)

    if not formatted_output then
      notify("LLM formatter failed: " .. tostring(run_err), vim.log.levels.ERROR)
      return
    end

    if not vim.api.nvim_buf_is_valid(bufnr) then
      notify("Formatted result ready, but buffer is no longer valid", vim.log.levels.WARN)
      return
    end

    local formatted_lines = split_lines(formatted_output)
    local ok, set_err = pcall(vim.api.nvim_buf_set_lines, bufnr, body_start - 1, body_end, false, formatted_lines)
    if not ok then
      notify("Failed to apply LLM formatted code: " .. tostring(set_err), vim.log.levels.ERROR)
      return
    end

    notify("Formatted " .. normalized_lang .. " code block with LLM")
  end)
  if not ok then
    unlock_buffer_for_llm(bufnr)
    notify("Failed to start LLM formatter: " .. tostring(async_err), vim.log.levels.ERROR)
  end
end

return M
