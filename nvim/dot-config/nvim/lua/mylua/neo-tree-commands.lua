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

-- Helper function to get the buffer to the right
local function _get_right_buffer()
  vim.cmd("wincmd l")
  local target_buf_id = vim.api.nvim_get_current_buf()
  vim.cmd("wincmd h")

  if target_buf_id and vim.api.nvim_buf_is_loaded(target_buf_id) then
    return target_buf_id
  else
    return nil
  end
end

-- Helper function to add lines to a buffer
local function _add_lines_to_buffer(buf_id, lines)
  if buf_id then
    vim.api.nvim_buf_set_lines(buf_id, -1, -1, false, lines)
    return true
  else
    vim.notify("Could not find a valid buffer to the right.", vim.log.levels.WARN)
    return false
  end
end

function M.copy_path_to_right_buffer(state)
  --- Copy selected node paths into the buffer to the right.
  --
  -- Behavior:
  -- - If a file node is selected, its relative path (prefixed with '@')
  --   is appended to the buffer in the right-hand window.
  -- - If a directory node is selected, all files directly inside that
  --   directory (depth 1 only, no subdirectories) are appended.
  --
  -- The function assumes there is a window to the right of neo-tree.
  -- If no valid right-hand buffer exists, a warning is shown.
  --
  -- @param state table Neo-tree command state
  local node = state.tree:get_node()
  if not node or node.type == "root" then
    vim.notify("No file or directory selected.", vim.log.levels.WARN)
    return
  end

  local paths_to_add = {}

  if node.type == "file" then
    local filepath = node:get_id()
    table.insert(paths_to_add, "@" .. vim.fn.fnamemodify(filepath, ":."))
  elseif node.type == "directory" then
    local dirpath = node.path
    vim.notify("Listing paths in directory '" .. dirpath .. "' (depth 1 only).", vim.log.levels.INFO)

    for _, name in ipairs(vim.fn.readdir(dirpath)) do
      local full_path = dirpath .. "/" .. name
      if vim.fn.isdirectory(full_path) == 0 then -- Only add if it's not a directory
        table.insert(paths_to_add, "@" .. vim.fn.fnamemodify(full_path, ":."))
      end
    end

    if #paths_to_add == 0 then
      vim.notify("Directory is empty: " .. dirpath, vim.log.levels.INFO)
      return
    end
  else
    vim.notify("Unsupported node type.", vim.log.levels.WARN)
    return
  end

  -- Add paths to right-hand buffer
  _add_lines_to_buffer(_get_right_buffer(), paths_to_add)
end

function M.copy_file_content_to_scratch(state)
  --- Copy file contents into a reusable scratch buffer.
  --
  -- Behavior:
  -- - If a file node is selected, its full contents are appended to the
  --   scratch buffer.
  -- - If a directory node is selected, all readable files directly within
  --   that directory (depth 1 only) are appended.
  --
  -- Each file is added with:
  -- - A header line showing the absolute file path
  -- - The full file contents
  -- - A visual separator between files
  --
  -- The scratch buffer is opened in a vertical split and reused across
  -- invocations.
  --
  -- @param state table Neo-tree command state
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
    local header = { "--- " .. vim.fn.fnamemodify(filepath_to_add, ":p") .. " ---" }
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

-- Build a pretty printed directory tree with proper structure and icons
local function _build_pretty_tree(dirpath)
  -- Get all files and directories first
  local git_root = vim.fn.systemlist({ "git", "-C", dirpath, "rev-parse", "--show-toplevel" })
  local all_items = {}
  local base_path = dirpath:gsub("/$", "")

  if vim.v.shell_error == 0 and #git_root > 0 then
    local repo_root = git_root[1]
    local git_files = vim.fn.systemlist({
      "git",
      "-C",
      repo_root,
      "ls-files",
      "-c",
      "--others",
      "--exclude-standard",
      "--",
      dirpath,
    })

    local seen_dirs = {}
    for _, rel in ipairs(git_files) do
      local full_path = repo_root .. "/" .. rel
      table.insert(all_items, full_path)

      local dir = vim.fn.fnamemodify(full_path, ":h")
      while dir and dir:sub(1, #base_path) == base_path and dir ~= base_path do
        if not seen_dirs[dir] then
          table.insert(all_items, dir)
          seen_dirs[dir] = true
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
          break
        end
        dir = parent
      end
    end
  else
    -- Fallback: plain recursive scan
    local files = vim.fn.systemlist({ "find", dirpath, "-type", "f" })
    local dirs = vim.fn.systemlist({ "find", dirpath, "-type", "d" })
    all_items = vim.list_extend(dirs, files)
  end

  -- Build tree structure
  local tree_structure = {}

  -- Helper function to add items to tree
  local function add_path(path, is_dir)
    local parts = {}
    for part in path:gmatch("([^/]+)") do
      table.insert(parts, part)
    end

    local current = tree_structure
    for i, part in ipairs(parts) do
      local is_last = i == #parts
      if is_last then
        if is_dir then
          current[part] = current[part] or {}
        else
          current[part] = false
        end
      else
        if current[part] == false then
          current[part] = {}
        end
        current[part] = current[part] or {}
        current = current[part]
      end
    end
  end

  -- Add all items to tree structure
  for _, path in ipairs(all_items or {}) do
    if path ~= dirpath then -- Skip the root directory itself
      local rel_path = path:sub(base_path:len() + 2) -- Remove base path and leading /
      local is_dir = vim.fn.isdirectory(path) == 1
      add_path(rel_path, is_dir)
    end
  end

  -- Generate pretty printed tree lines
  local function format_tree(node, prefix)
    local lines = {}
    local sorted_keys = {}

    for k in pairs(node) do
      table.insert(sorted_keys, k)
    end
    table.sort(sorted_keys)

    for i, key in ipairs(sorted_keys) do
      local value = node[key]
      local is_last = i == #sorted_keys
      local is_dir = type(value) == "table"
      local name = is_dir and (key .. "/") or key

      local current_prefix = prefix .. (is_last and "`-- " or "|-- ")
      local line = current_prefix .. name
      table.insert(lines, line)

      if is_dir and next(value) ~= nil then
        local next_prefix = prefix .. (is_last and "    " or "|   ")
        local child_lines = format_tree(value, next_prefix)
        vim.list_extend(lines, child_lines)
      end
    end

    return lines
  end

  -- Start with root directory name
  local root_name = vim.fn.fnamemodify(dirpath, ":t")
  local lines = { root_name .. "/" }
  vim.list_extend(lines, format_tree(tree_structure, ""))

  return lines
end

function M.copy_directory_tree_to_right_buffer(state)
  --- Copy a pretty printed recursive directory tree into the buffer to the right.
  --
  -- Behavior:
  -- - Works only on directory nodes.
  -- - Recursively lists all files and subdirectories with visual tree structure.
  -- - Uses emojis for visual clarity: 📂 for directories with content, 📁 for empty dirs, 📄 for files
  -- - Respects .gitignore when inside a git repository.
  -- - Appends results to the buffer in the right-hand window.
  --
  -- @param state table Neo-tree command state
  local node = state.tree:get_node()
  if not node then
    vim.notify("No node selected.", vim.log.levels.WARN)
    return
  end

  if node.type ~= "directory" then
    vim.notify("Directory tree copy only works on directories.", vim.log.levels.WARN)
    return
  end

  local dirpath = node.path
  vim.notify("Building pretty directory tree for '" .. dirpath .. "'...", vim.log.levels.INFO)

  local lines = _build_pretty_tree(dirpath)
  if #lines == 0 then
    vim.notify("No files found in directory tree.", vim.log.levels.INFO)
    return
  end

  -- Add tree lines to right-hand buffer
  _add_lines_to_buffer(_get_right_buffer(), lines)
end

return M
