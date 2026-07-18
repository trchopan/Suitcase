local M = {}

function M.setup(config)
  local clipboardLog = hs.logger.new("clipboard-edit", "warning")

  local function showError(message)
    clipboardLog.w(message)
    hs.alert.show(message, 2)
  end

  local function discard(path)
    if path then os.remove(path) end
  end

  local function isPlainText()
    local types = hs.pasteboard.pasteboardTypes()
    if not types then return true end
    for _, value in ipairs(types) do
      if value:match("^public%.image") or value:match("^public%.png")
        or value:match("^public%.jpeg") or value:match("^public%.tiff")
        or value:match("^com%.apple%.image") then
        return false
      end
    end
    for _, value in ipairs(types) do
      if value == "public.utf8-plain-text" or value == "public.text"
        or value == "NSStringPboardType" then return true end
    end
    return false
  end

  local function hasBinary(content)
    return content:find("[%z\001-\008\011\012\014-\031\127]") ~= nil
  end

  local function ensureDirectory()
    hs.fs.mkdir(config.home .. "/.local")
    hs.fs.mkdir(config.home .. "/.local/share")
    return hs.fs.mkdir(config.clipboardDir) or hs.fs.attributes(config.clipboardDir) ~= nil
  end

  local function prune()
    local files = {}
    for filename in hs.fs.dir(config.clipboardDir) do
      if filename:match("^clipboard_%d+_[%w%-]+%.md$") then
        local path = config.clipboardDir .. "/" .. filename
        local attributes = hs.fs.attributes(path)
        if attributes and attributes.mode == "file" then
          files[#files + 1] = {path = path, modification = attributes.modification or 0}
        end
      end
    end
    table.sort(files, function(left, right) return left.modification > right.modification end)
    for index = config.maxClipboardFiles + 1, #files do os.remove(files[index].path) end
  end

  local function writeFile(content)
    if not ensureDirectory() then return nil, "Unable to create clipboard directory" end
    local slug = content:sub(1, 50):lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
      :gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
    if slug == "" then slug = "untitled" end
    local timestamp = tostring(math.floor(hs.timer.secondsSinceEpoch()))
    local filename = "clipboard_" .. timestamp .. "_" .. slug .. ".md"
    local path = config.clipboardDir .. "/" .. filename
    local collision = 2
    while hs.fs.attributes(path) do
      filename = "clipboard_" .. timestamp .. "_" .. slug .. "-" .. collision .. ".md"
      path = config.clipboardDir .. "/" .. filename
      collision = collision + 1
    end
    local temporaryPath = path .. ".tmp-" .. tostring(math.floor(hs.timer.secondsSinceEpoch() * 1000))
    local file = io.open(temporaryPath, "wb")
    if not file then return nil, "Unable to create clipboard file" end
    file:write(content)
    file:close()
    if not os.rename(temporaryPath, path) then
      os.remove(temporaryPath)
      return nil, "Unable to finalize clipboard file"
    end
    prune()
    return path
  end

  local function sessionExists()
    local result = os.execute(config.tmux .. " has-session -t " .. config.editSession .. " 2>/dev/null")
    return result == true or result == 0
  end

  local function cleanup(existingSession, socketAttributes)
    local homeAttributes = hs.fs.attributes(config.home)
    if socketAttributes and (not homeAttributes or socketAttributes.uid ~= homeAttributes.uid) then
      showError("Neovim socket belongs to another user")
      return false
    end
    local details = {}
    if existingSession then details[#details + 1] = "tmux session " .. config.editSession end
    if socketAttributes then details[#details + 1] = "Neovim socket " .. config.nvimSocket end
    local choice = hs.dialog.blockAlert("Clipboard editor cleanup",
      "Existing editor state was found (" .. table.concat(details, " and ")
        .. "). Remove it and start a fresh clipboard editor?",
      "Clean up and continue", "Cancel", "warning")
    if choice ~= "Clean up and continue" then return false end
    if existingSession then os.execute(config.tmux .. " kill-session -t " .. config.editSession .. " 2>/dev/null") end
    if socketAttributes and not os.remove(config.nvimSocket) then
      showError("Unable to remove existing Neovim socket")
      return false
    end
    return true
  end

  local function startSession()
    os.remove(config.nvimSocket)
    local task = hs.task.new(config.tmux, nil, {
      "new-session", "-d", "-s", config.editSession, "-c", config.clipboardDir,
      config.fish, "-lic", "exec " .. config.nvim .. " --listen " .. config.nvimSocket,
    })
    return task and task:start()
  end

  local function ensureSession()
    local existingSession = sessionExists()
    local socketAttributes = hs.fs.attributes(config.nvimSocket)
    local homeAttributes = hs.fs.attributes(config.home)
    local socketBelongsToUser = socketAttributes and homeAttributes
      and socketAttributes.uid == homeAttributes.uid
    if existingSession and socketAttributes and socketAttributes.mode == "socket" and socketBelongsToUser then
      return true
    end
    if existingSession or socketAttributes then
      if not cleanup(existingSession, socketAttributes) then return false end
    end
    return startSession()
  end

  local function floatWindow(window, attempts)
    if not window or attempts <= 0 then return end
    local windowID = window:id()
    if not windowID then return end
    local query = hs.task.new(config.yabai, function(exitCode, output)
      if exitCode == 0 then
        local details = hs.json.decode(output)
        if details then
          if not details["is-floating"] then
            hs.task.new(config.yabai, nil, {"-m", "window", tostring(windowID), "--toggle", "float"}):start()
          end
          return
        end
      end
      hs.timer.doAfter(0.1, function() floatWindow(window, attempts - 1) end)
    end, {"-m", "query", "--windows", "--window", tostring(windowID)})
    if query then query:start() end
  end

  local function openGhostty(path)
    local ghostty = hs.application.get("Ghostty") or hs.application.open("Ghostty", 2, true)
    if not ghostty then return false end
    os.execute(config.tmux .. " set-option -t " .. config.editSession .. " set-titles on")
    os.execute(config.tmux .. " set-option -t " .. config.editSession .. " set-titles-string " .. config.ghosttyTitle)
    for _, window in ipairs(ghostty:allWindows()) do
      local title = window:title() or ""
      if title:find(config.ghosttyTitle, 1, true) or title:find(config.editSession, 1, true) then
        window:focus()
        floatWindow(window, 20)
        return true
      end
    end
    ghostty:activate()
    if not ghostty:selectMenuItem("New Window") then return false end
    hs.timer.doAfter(0.5, function()
      local newWindow = ghostty:focusedWindow()
      if not newWindow then
        discard(path)
        showError("Unable to focus new Ghostty window")
        return
      end
      local windowID = newWindow:id()
      if windowID then os.execute(config.yabai .. " -m window " .. tostring(windowID) .. " --toggle float") end
      hs.eventtap.keyStrokes("exec " .. config.tmux .. " attach-session -t " .. config.editSession)
      hs.eventtap.keyStroke({}, "return")
      floatWindow(newWindow, 20)
    end)
    return true
  end

  local function openInNvim(path)
    local task = hs.task.new(config.nvr, function(exitCode)
      if exitCode == 0 then
        hs.alert.show("Opened clipboard in Neovim")
      else
        discard(path)
        showError("Unable to open clipboard in Neovim")
      end
    end, {"--servername", config.nvimSocket, "--nostart", "--remote", path})
    return task and task:start()
  end

  local function waitForNvim(path, attempts)
    local attributes = hs.fs.attributes(config.nvimSocket)
    if attributes and attributes.mode == "socket" then
      if not openInNvim(path) then
        discard(path)
        showError("Unable to open Neovim")
      end
      return
    end
    if attempts <= 0 then
      discard(path)
      showError("Neovim did not start")
      return
    end
    hs.timer.doAfter(0.1, function() waitForNvim(path, attempts - 1) end)
  end

  hs.hotkey.bind({"cmd", "alt"}, "E", function()
    if not hs.fs.attributes(config.nvr) then return showError("nvr is not installed; install neovim-remote") end
    if not isPlainText() then return showError("Clipboard is not plain text") end
    local content = hs.pasteboard.getContents()
    if not content or content == "" then return showError("Clipboard is empty") end
    if #content > config.maxClipboardBytes then return showError("Clipboard exceeds 5 MiB") end
    if hasBinary(content) then return showError("Clipboard contains binary data") end
    local path, errorMessage = writeFile(content)
    if not path then return showError(errorMessage) end
    if not ensureSession() then
      discard(path)
      return showError("Unable to start tmux Neovim session")
    end
    if not openGhostty(path) then
      discard(path)
      return showError("Unable to open Ghostty")
    end
    waitForNvim(path, 40)
  end)
end

return M
