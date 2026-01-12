-- Visual selection -> OpenAI structured output {files:[...]} -> concat into scratch.
--
-- Usage:
--   1) Type prompt anywhere
--   2) Visually select it
--   3) :AIRequestFilesContent
--
-- Requirements:
--   - curl
--   - rg (ripgrep)
--   - secret-key openai personal
--
-- Structured Outputs (json_schema) requires text.format.name in your environment.

local M = {}

M.config = {
  model = "gpt-5-nano-2025-08-07", -- override in setup() if desired
  key_cmd = "secret-key openai personal",
  openai_url = "https://api.openai.com/v1/responses",

  rg_cmd = "rg --files --hidden --glob '!.git/**' --no-messages",
  max_candidates = 4000,
  timeout_ms = 120000,

  max_output_tokens = 512,
  max_output_tokens_retry = 1536,
}

-- -------------------------
-- Helpers
-- -------------------------

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function system(cmd)
  local out = vim.fn.system(cmd)
  local code = vim.v.shell_error
  return out, code
end

local function notify_err(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end
local function notify_warn(msg)
  vim.notify(msg, vim.log.levels.WARN)
end

local function json_decode_or_err(s, context)
  local ok, obj = pcall(vim.json.decode, s)
  if ok then
    return obj, nil
  end
  return nil, ("Failed to decode JSON (%s). Raw:\n%s"):format(context or "unknown", s)
end

local function get_api_key()
  local out, code = system(M.config.key_cmd)
  if code ~= 0 then
    return nil, ("API key command failed (exit %d): %s"):format(code, M.config.key_cmd)
  end
  local key = trim(out)
  if key == "" then
    return nil, ("API key command returned empty output: %s"):format(M.config.key_cmd)
  end
  return key, nil
end

local function get_project_root()
  return vim.fn.getcwd()
end

local function list_project_files()
  local out, code = system(M.config.rg_cmd)
  if code ~= 0 then
    return nil, ("Failed to list files via rg (exit %d). Is ripgrep installed?"):format(code)
  end

  local files = {}
  for line in out:gmatch("[^\r\n]+") do
    table.insert(files, line)
    if #files >= M.config.max_candidates then
      break
    end
  end
  return files, nil
end

local function realpath(path)
  return vim.loop.fs_realpath(path)
end

local function is_within_root(root_real, candidate_path)
  local cand_real = realpath(candidate_path)
  if not cand_real then
    return false
  end
  local root = root_real
  if root:sub(-1) ~= "/" then
    root = root .. "/"
  end
  return cand_real:sub(1, #root) == root
end

local function get_response_output_text(resp)
  if type(resp) ~= "table" then
    return nil
  end

  if type(resp.output_text) == "string" and resp.output_text ~= "" then
    return resp.output_text
  end

  if type(resp.output) ~= "table" then
    return nil
  end

  local chunks = {}
  for _, item in ipairs(resp.output) do
    if item.type == "message" and type(item.content) == "table" then
      for _, c in ipairs(item.content) do
        if (c.type == "output_text" or c.type == "text") and type(c.text) == "string" then
          table.insert(chunks, c.text)
        end
      end
    end
  end

  if #chunks == 0 then
    return nil
  end
  return table.concat(chunks, "\n")
end

local function is_token_truncation(err)
  if type(err) ~= "string" then
    return false
  end
  return err:match("max_output_tokens") ~= nil
end

-- -------------------------
-- Curl with HTTP status capture
-- -------------------------

local function curl_post_json(url, api_key, payload_tbl)
  local payload = vim.json.encode(payload_tbl)

  local cmd = table.concat({
    "curl -sS",
    "--max-time " .. math.floor(M.config.timeout_ms / 1000),
    "-H " .. vim.fn.shellescape("Authorization: Bearer " .. api_key),
    "-H " .. vim.fn.shellescape("Content-Type: application/json"),
    "-d " .. vim.fn.shellescape(payload),
    "-w " .. vim.fn.shellescape("\nHTTPSTATUS:%{http_code}"),
    vim.fn.shellescape(url),
  }, " ")

  local out, code = system(cmd)
  if code ~= 0 then
    return nil, ("curl failed (exit %d). Output:\n%s"):format(code, out)
  end

  local body, status = out:match("^(.*)\nHTTPSTATUS:(%d%d%d)$")
  if not body or not status then
    return nil, ("Unexpected curl output (missing HTTPSTATUS). Raw:\n%s"):format(out)
  end

  status = tonumber(status)
  if status < 200 or status >= 300 then
    return nil, ("HTTP %d from OpenAI. Body:\n%s"):format(status, body)
  end

  return body, nil
end

-- -------------------------
-- OpenAI call (Structured Outputs)
-- -------------------------

local function build_schema_files_only()
  return {
    type = "object",
    properties = {
      files = { type = "array", items = { type = "string" } },
    },
    required = { "files" },
    additionalProperties = false,
  }
end

local function build_payload(system_msg, user_msg, max_output_tokens)
  return {
    model = M.config.model,
    input = {
      { role = "system", content = system_msg },
      { role = "user", content = user_msg },
    },
    max_output_tokens = max_output_tokens,
    text = {
      format = {
        type = "json_schema",
        name = "file_selection", -- REQUIRED per your API error
        strict = true,
        schema = build_schema_files_only(),
      },
    },
  }
end

local function call_openai_select_files(api_key, user_prompt, candidates)
  local system_msg = table.concat({
    "You are a codebase-aware assistant.",
    "Select the minimal set of files needed to satisfy the user request.",
    "Only choose paths from the provided candidate list (exact string match).",
    'Return {"files": [...]} per the schema. If nothing matches, return {"files":[]}.',
  }, "\n")

  local user_msg = table.concat({
    "USER REQUEST:",
    user_prompt,
    "",
    "CANDIDATE FILES (relative to project root):",
    table.concat(candidates, "\n"),
  }, "\n")

  local function attempt(max_output_tokens)
    local payload_tbl = build_payload(system_msg, user_msg, max_output_tokens)
    local raw_body, req_err = curl_post_json(M.config.openai_url, api_key, payload_tbl)
    if not raw_body then
      return nil, req_err
    end

    local resp, env_err = json_decode_or_err(raw_body, "OpenAI response envelope")
    if not resp then
      return nil, env_err
    end

    if resp.status == "incomplete" then
      local why = resp.incomplete_details and resp.incomplete_details.reason or "unknown"
      return nil, ("OpenAI response incomplete (reason: %s)."):format(why)
    end

    local out_text = get_response_output_text(resp)
    if not out_text then
      return nil, ("OpenAI response had no output_text. Envelope:\n%s"):format(raw_body)
    end

    local obj, obj_err = json_decode_or_err(out_text, "structured output")
    if not obj then
      return nil, obj_err
    end

    if type(obj.files) ~= "table" then
      return nil, ("Structured output missing 'files' array. Raw output_text:\n%s"):format(out_text)
    end

    return obj, nil
  end

  local obj, err = attempt(M.config.max_output_tokens)
  if obj then
    return obj, nil
  end

  if is_token_truncation(err) then
    local obj2, err2 = attempt(M.config.max_output_tokens_retry)
    if obj2 then
      return obj2, nil
    end
    return nil, err2 or err
  end

  return nil, err
end

-- -------------------------
-- Scratch output
-- -------------------------

local function read_file_lines(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil, ("Failed to read file: %s"):format(path)
  end
  return lines, nil
end

local function normalize_lines(lines)
  local out = {}
  for _, s in ipairs(lines or {}) do
    if s == nil then
      -- skip
    elseif type(s) ~= "string" then
      s = tostring(s)
      table.insert(out, s)
    elseif s:find("\n", 1, true) or s:find("\r", 1, true) then
      s = s:gsub("\r\n", "\n"):gsub("\r", "\n")
      local parts = vim.split(s, "\n", { plain = true })
      for _, p in ipairs(parts) do
        table.insert(out, p)
      end
    else
      table.insert(out, s)
    end
  end
  return out
end

local function open_scratch_with_content(title, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  pcall(vim.api.nvim_buf_set_name, buf, title)

  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

  local safe = normalize_lines(lines)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, safe)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

-- -------------------------
-- Prompt acquisition (visual selection / range)
-- -------------------------

local function get_visual_selection_text(bufnr)
  local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
  local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")

  local srow, scol = start_pos[1], start_pos[2]
  local erow, ecol = end_pos[1], end_pos[2]

  if srow == 0 or erow == 0 then
    return nil, "No visual selection found. Select your prompt text first."
  end

  if (erow < srow) or (erow == srow and ecol < scol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end

  local lines = vim.api.nvim_buf_get_text(bufnr, srow - 1, scol, erow - 1, ecol + 1, {})

  local text = trim(table.concat(lines, "\n"))
  if text == "" then
    return nil, "Visual selection is empty."
  end
  return text, nil
end

-- -------------------------
-- Core pipeline
-- -------------------------

local function run_pipeline(user_prompt)
  local api_key, key_err = get_api_key()
  if not api_key then
    notify_err(key_err)
    return
  end

  local root = get_project_root()
  local root_real = realpath(root)
  if not root_real then
    notify_err("Unable to resolve project root: " .. root)
    return
  end

  local candidates, list_err = list_project_files()
  if not candidates then
    notify_err(list_err)
    return
  end

  local selection, sel_err = call_openai_select_files(api_key, user_prompt, candidates)
  if not selection then
    vim.api.nvim_echo({ { sel_err, "Error" } }, true, {})
    notify_err(sel_err)
    return
  end

  local files = selection.files or {}

  local out_lines = {}
  table.insert(out_lines, "# Project scratch pad")
  table.insert(out_lines, "")
  table.insert(out_lines, "## Prompt")
  table.insert(out_lines, user_prompt)
  table.insert(out_lines, "")
  table.insert(out_lines, "## Included files")

  if #files == 0 then
    table.insert(out_lines, "_None selected._")
    open_scratch_with_content("Scratch: project concat", out_lines)
    return
  end

  for _, f in ipairs(files) do
    table.insert(out_lines, "- " .. f)
  end
  table.insert(out_lines, "")
  table.insert(out_lines, "## Concatenated contents")
  table.insert(out_lines, "")

  for _, rel in ipairs(files) do
    local abs = root .. "/" .. rel
    table.insert(out_lines, ("### %s"):format(rel))

    if not is_within_root(root_real, abs) then
      table.insert(out_lines, "")
      table.insert(out_lines, "_Skipped (outside project root)._")
      table.insert(out_lines, "")
    else
      local lines, rerr = read_file_lines(abs)
      table.insert(out_lines, "```")
      if lines then
        for _, ln in ipairs(lines) do
          table.insert(out_lines, ln)
        end
      else
        table.insert(out_lines, ("<ERROR: %s>"):format(rerr))
      end
      table.insert(out_lines, "```")
      table.insert(out_lines, "")
    end
  end

  open_scratch_with_content("Scratch: project concat", out_lines)
end

-- -------------------------
-- Public API
-- -------------------------

function M.concat_from_visual_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local text, err = get_visual_selection_text(bufnr)
  if not text then
    notify_warn(err)
    return
  end
  run_pipeline(text)
end

function M.concat_from_range(line1, line2)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
  local text = trim(table.concat(lines, "\n"))
  if text == "" then
    notify_warn("Selected range is empty.")
    return
  end
  run_pipeline(text)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_user_command("AIRequestFilesContent", function(cmd)
    if cmd.range == 2 then
      M.concat_from_range(cmd.line1, cmd.line2)
    else
      M.concat_from_visual_selection()
    end
  end, { desc = "AIRequestFilesContent: selection/range -> OpenAI file list -> concat into scratch", range = true })
end

return M
