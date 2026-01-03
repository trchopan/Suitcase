local M = {}

-- Helper function for scratch buffer management
local function _get_or_create_scratch_buffer(state)
  local target_bufnr = state.commands._scratch_bufnr
  local current_win = vim.api.nvim_get_current_win() -- Store current window

  if not target_bufnr or not vim.api.nvim_buf_is_loaded(target_bufnr) then
    target_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(target_bufnr, "Scratchpad")
    vim.bo[target_bufnr].buftype = "nofile"
    vim.bo[target_bufnr].bufhidden = "wipe"
    vim.bo[target_bufnr].swapfile = false
    vim.bo[target_bufnr].modifiable = true
    state.commands._scratch_bufnr = target_bufnr

    vim.cmd("vnew")
    vim.api.nvim_win_set_buf(0, target_bufnr)
    vim.api.nvim_buf_set_lines(target_bufnr, 0, -1, false, {})
  else
    local found_win = nil
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(winid) == target_bufnr then
        found_win = winid
        break
      end
    end

    if found_win then
      vim.api.nvim_set_current_win(found_win)
    else
      vim.cmd("vnew")
      vim.api.nvim_win_set_buf(0, target_bufnr)
    end
  end
  return target_bufnr, current_win
end

function M.copy_path_to_right_buffer(state)
  local node = state.tree:get_node()
  if not node or node.type == "root" then
    vim.notify("No file or directory selected.", vim.log.levels.WARN)
    return
  end

  local filepath = node:get_id()
  local relative_path = vim.fn.fnamemodify(filepath, ":.")

  vim.cmd("wincmd l")
  local target_buf_id = vim.api.nvim_get_current_buf()
  vim.cmd("wincmd h")

  if target_buf_id ~= nil and vim.api.nvim_buf_is_loaded(target_buf_id) then
    vim.api.nvim_buf_set_lines(target_buf_id, -1, -1, false, { relative_path })
  else
    vim.notify("Could not find a valid buffer to the right.", vim.log.levels.WARN)
  end
end

function M.copy_file_content_to_clipboard(state)
  local node = state.tree:get_node()
  if not node or node.type ~= "file" then
    vim.notify("Please select a file to copy its content.", vim.log.levels.WARN)
    return
  end

  local filepath = node.path
  local lines = vim.fn.readfile(filepath)
  if #lines > 0 then
    local content = table.concat(lines, "\n")
    vim.fn.setreg("*", content)
    vim.notify("File content copied to system clipboard!", vim.log.levels.INFO)
  else
    vim.notify("File is empty or could not be read.", vim.log.levels.WARN)
  end
end

function M.copy_file_content_to_scratch(state)
  local node = state.tree:get_node()
  if not node then
    vim.notify("No node selected.", vim.log.levels.WARN)
    return
  end

  local files_to_process = {}
  if node.type == "file" then
    table.insert(files_to_process, node.path)
  elseif node.type == "directory" then
    local dirpath = node.path
    -- All files directly within the selected directory will be listed.
    vim.notify("Listing files in directory '" .. dirpath .. "' (depth 1 only).", vim.log.levels.INFO)
    for _, filename in ipairs(vim.fn.readdir(dirpath)) do
      local full_path = dirpath .. "/" .. filename
      if vim.fn.isdirectory(full_path) == 0 and vim.fn.filereadable(full_path) == 1 then
        table.insert(files_to_process, full_path)
      end
    end

    if #files_to_process == 0 then
      vim.notify("No files found in directory " .. dirpath .. " (depth 1).", vim.log.levels.INFO)
      return
    end
  else
    vim.notify("Please select a file or a directory.", vim.log.levels.WARN)
    return
  end

  local target_bufnr, current_win = _get_or_create_scratch_buffer(state)
  if not target_bufnr then
    return
  end

  for _, filepath_to_add in ipairs(files_to_process) do
    if vim.fn.filereadable(filepath_to_add) == 0 then
      vim.notify("File '" .. filepath_to_add .. "' could not be read. Skipping.", vim.log.levels.WARN)
      goto continue_loop
    elseif vim.fn.getfsize(filepath_to_add) == 0 then
      vim.notify("File '" .. filepath_to_add .. "' is empty. Skipping.", vim.log.levels.INFO)
      goto continue_loop
    end

    local lines = vim.fn.readfile(filepath_to_add)
    local header = { "-- " .. vim.fn.fnamemodify(filepath_to_add, ":p") .. " --" }
    local separator = { "", string.rep("-", 80), "", "" }

    vim.bo[target_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(target_bufnr, -1, -1, false, header)
    vim.api.nvim_buf_set_lines(target_bufnr, -1, -1, false, lines)
    vim.api.nvim_buf_set_lines(target_bufnr, -1, -1, false, separator)
    ::continue_loop::
  end

  vim.cmd("normal! G")
  vim.cmd("filetype detect")
  vim.notify("Content of " .. #files_to_process .. " files added to scratch buffer!", vim.log.levels.INFO)
end

return M
