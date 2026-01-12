local M = {}

-- Percent-encode a string for use in a URL query
local function urlencode(str)
  if not str then
    return ""
  end
  return (str:gsub("[^%w%.%-_~]", function(ch)
    return string.format("%%%02X", string.byte(ch))
  end))
end

-- Find a URL under the cursor on the current line
local function get_url_under_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2] + 1 -- 1-based col for easier comparison
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""

  local s, e, url
  local matches = {}
  local i = 1
  while true do
    local start, finish, found = line:find("(https?://[%w%p%-_/%.]+)", i)
    if not start then
      break
    end
    table.insert(matches, { s = start, e = finish, url = found })
    i = finish + 1
  end

  for _, m in ipairs(matches) do
    if col >= m.s and col <= m.e then
      return m.url
    end
  end

  -- Fallback: return the first URL on the line if present
  if #matches > 0 then
    return matches[1].url
  end
  return nil
end

-- Fetch markdown content from the URL using the external tool
local function fetch_markdown(url)
  if not url then
    return nil, "no url found under cursor"
  end
  local encoded = urlencode(url)
  local tool_url =
    string.format("https://urltomarkdown.herokuapp.com/?url=%s&title=true&links=true&clean=true", encoded)

  local ok, resp = pcall(function()
    return vim.fn.system({ "curl", "-s", "-L", tool_url })
  end)

  if not ok then
    return nil, "curl invocation failed"
  end
  if vim.v.shell_error ~= 0 then
    return nil, resp or "non-zero exit from curl"
  end

  return resp
end

-- Open a new scratch markdown buffer and fill it with content
local function open_scratch_markdown(content)
  vim.cmd("enew") -- create a new empty buffer and window
  local bufnr = vim.api.nvim_get_current_buf()

  -- Split content into lines, preserving blank lines
  local lines = vim.split(content, "\n", { plain = true, trimempty = false })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })

  return bufnr
end

-- Public API: download the URL under the cursor and show in a temp markdown buffer
function M.download_at_cursor()
  local url = get_url_under_cursor()
  if not url then
    vim.notify("No URL found under cursor", vim.log.levels.ERROR)
    return
  end

  local content, err = fetch_markdown(url)
  if not content then
    vim.notify("Failed to fetch markdown: " .. tostring(err or ""), vim.log.levels.ERROR)
    return
  end

  open_scratch_markdown(content)
  return true
end

-- Optional setup (reserved for future options)
-- filepath: lua/mylua/mix_usage_rules.lua
-- Wire up a simple user command to download URL at cursor to a markdown scratch buffer
-- vim.api.nvim_create_user_command('UrlToMarkdown', function()
--   require('mylua.url_to_markdown').download_at_cursor()
-- end, { desc = 'Download URL at cursor to markdown in a scratch buffer' })

return M
