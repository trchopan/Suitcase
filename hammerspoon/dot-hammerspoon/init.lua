-- ~/.hammerspoon/init.lua

hs.alert.show("Hammerspoon loaded")

local home = os.getenv("HOME")
local spoonsDir = home .. "/.hammerspoon/Spoons"

local function ensureSpoon(name, zipUrl)
  local spoonPath = string.format("%s/%s.spoon", spoonsDir, name)
  local initPath = spoonPath .. "/init.lua"

  if hs.fs.attributes(initPath) then
    return true
  end

  hs.alert.show(string.format("Repairing %s.spoon", name), 1)

  hs.fs.mkdir(spoonsDir)

  local zipPath = string.format("/tmp/%s.spoon.zip", name)
  local command = string.format(
    "rm -rf %q && curl -fsSL %q -o %q && /usr/bin/unzip -oq %q -d %q",
    spoonPath,
    zipUrl,
    zipPath,
    zipPath,
    spoonsDir
  )

  hs.execute(command, true)

  if hs.fs.attributes(initPath) then
    return true
  end

  hs.alert.show(string.format("Failed to install %s.spoon", name), 2)
  return false
end

ensureSpoon("SpoonInstall", "https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip")
ensureSpoon("EmmyLua", "https://github.com/Hammerspoon/Spoons/raw/master/Spoons/EmmyLua.spoon.zip")

local spoonInstallLoaded = hs.loadSpoon("SpoonInstall")
if spoonInstallLoaded and spoon.SpoonInstall then
  spoon.SpoonInstall:andUse("EmmyLua")
else
  hs.alert.show("SpoonInstall is unavailable", 2)
end

-- ------------------------------------------------------------
-- Shell runner
-- ------------------------------------------------------------

local fish = "/opt/homebrew/bin/fish"
local layoutLog = hs.logger.new("layout", "warning")

local function runShell(command, onExit)
  local task = hs.task.new(fish, onExit, {"-lc", command})
  if task then
    task:start()
    return true
  end

  return false
end

local function run(command)
  return function()
    if not runShell(command, nil) then
      layoutLog.e("failed to start shell task")
    end
  end
end

local function bind(mods, key, command)
  hs.hotkey.bind(mods, key, run(command))
end

-- ------------------------------------------------------------
-- Modifiers
-- ------------------------------------------------------------

local shift_alt = {"shift", "alt"}
local shift_ctrl = {"shift", "ctrl"}
local hyper = {"shift", "alt", "ctrl"}

-- ------------------------------------------------------------
-- Focus window
-- ------------------------------------------------------------

bind(shift_alt, "j", [[
set id (yabai -m query --windows --window next | jq -r '.id // empty')
if test -n "$id"
    yabai -m window --focus next
else
    yabai -m window --focus first
end
]])

bind(shift_alt, "k", [[
set id (yabai -m query --windows --window prev | jq -r '.id // empty')
if test -n "$id"
    yabai -m window --focus prev
else
    yabai -m window --focus last
end
]])

-- ------------------------------------------------------------
-- Balance size of windows
-- ------------------------------------------------------------

bind(shift_alt, "0", [[
yabai -m space --balance
]])

-- ------------------------------------------------------------
-- Flip windows
-- ------------------------------------------------------------

bind(shift_ctrl, "space", [[
yabai -m space --mirror y-axis
]])

-- ------------------------------------------------------------
-- Space move
-- ------------------------------------------------------------

bind(hyper, "1", [[
yabai -m window --space 1
]])

bind(hyper, "2", [[
yabai -m window --space 2
]])

-- ------------------------------------------------------------
-- Window location
-- ------------------------------------------------------------

bind(hyper, "3", [[
yabai -m window --grid 8:12:2:1:8:6
]])

bind(hyper, "5", [[
yabai -m window --grid 1:1:0:0:1:1
]])

bind(hyper, "4", [[
yabai -m window --grid 1:2:0:0:1:1
]])

bind(hyper, "6", [[
yabai -m window --grid 1:2:1:0:1:1
]])

bind(hyper, "9", [[
yabai -m window --grid 1:3:2:0:1:1
]])

-- ------------------------------------------------------------
-- Move / swap window
-- ------------------------------------------------------------

bind(shift_alt, "return", [[
yabai -m window --swap first
]])

bind(hyper, "j", [[
yabai -m window --swap next
]])

bind(hyper, "k", [[
yabai -m window --swap prev
]])

bind(hyper, "up", [[
yabai -m window --move rel:0:-100
]])

bind(hyper, "down", [[
yabai -m window --move rel:0:100
]])

bind(hyper, "left", [[
yabai -m window --move rel:-100:0
]])

bind(hyper, "right", [[
yabai -m window --move rel:100:0
]])

-- ------------------------------------------------------------
-- Display move
-- ------------------------------------------------------------

bind(hyper, "h", [[
yabai -m window --display prev
]])

bind(hyper, "l", [[
yabai -m window --display next
]])

-- Optional display focus, currently matching your commented skhd config:
--
-- bind(shift_alt, "h", [[
-- yabai -m display --focus prev
-- ]])
--
-- bind(shift_alt, "l", [[
-- yabai -m display --focus next
-- ]])

-- ------------------------------------------------------------
-- Resize window
--
-- skhd raw keycodes:
--   0x1B = 27 = minus
--   0x18 = 24 = equals
-- ------------------------------------------------------------

bind(shift_alt, 27, [[
yabai -m window --resize bottom_right:-75:0
]])

bind(shift_alt, 24, [[
yabai -m window --resize bottom_right:75:0
]])

bind(hyper, 27, [[
yabai -m window --resize bottom_right:0:-75
]])

bind(hyper, 24, [[
yabai -m window --resize bottom_right:0:75
]])

-- ------------------------------------------------------------
-- Focus specific app
-- ------------------------------------------------------------

local function focusApp(appName)
  return string.format([[
set id (yabai -m query --windows | jq -r '.[] | select(.app | contains("%s")) | .id' | head -n 1)
if test -n "$id"; and test "$id" != "null"
    yabai -m window --focus "$id"
end
]], appName)
end

bind(hyper, "a", focusApp("Ghostty"))
bind(hyper, "b", focusApp("Vivaldi"))
bind(hyper, "t", focusApp("Telegram"))
bind(hyper, "s", focusApp("Slack"))
bind(hyper, "e", focusApp("Emacs"))

bind(hyper, "x", [[
yabai -m window --toggle float
]])

-- ------------------------------------------------------------
-- Toggle layout
--
-- skhd raw keycode:
--   0x2C = 44 = slash on standard macOS ANSI layout
-- ------------------------------------------------------------

local lastLayoutToggleAt = 0
local layoutToggleDebounceSeconds = 0.2

hs.hotkey.bind(hyper, 44, function()
  local now = hs.timer.secondsSinceEpoch()
  if now - lastLayoutToggleAt < layoutToggleDebounceSeconds then
    return
  end
  lastLayoutToggleAt = now

  layoutLog.i("toggle layout/borders")

  local ok = runShell([[
set layout (yabai -m query --spaces --space | jq -r '.type' 2>/dev/null)

if test "$layout" = "bsp"
    yabai -m space --layout float
else
    yabai -m space --layout bsp
end

set layout (yabai -m query --spaces --space | jq -r '.type' 2>/dev/null)

if test "$layout" = "bsp"
    if not pgrep -x borders >/dev/null
        nohup borders active_color=0xff00FF31 inactive_color=0x00000000 width=5.0 >/dev/null 2>&1 &
    end
    yabai -m config top_padding 5
    yabai -m config bottom_padding 5
    yabai -m config left_padding 5
    yabai -m config right_padding 5
    yabai -m config window_gap 5
else
    if pgrep -x borders >/dev/null
        killall borders >/dev/null 2>&1
    end
    yabai -m config top_padding 0
    yabai -m config bottom_padding 0
    yabai -m config left_padding 0
    yabai -m config right_padding 0
    yabai -m config window_gap 0
end
]], function()
    layoutLog.i("toggle layout/borders done")
  end)

  if not ok then
    layoutLog.e("failed to start layout/borders task")
  end
end)

-- ------------------------------------------------------------
-- Automatic put layout to spaces
-- ------------------------------------------------------------

bind(hyper, "m", [[
set id (yabai -m query --windows | jq -r '.[] | select(.app | contains("Brave")) | .id' | head -n 1)
if test -n "$id"; and test "$id" != "null"
    yabai -m window --focus "$id"
    yabai -m window --space 1
end

set id (yabai -m query --windows | jq -r '.[] | select(.app | contains("Telegram")) | .id' | head -n 1)
if test -n "$id"; and test "$id" != "null"
    yabai -m window --focus "$id"
    yabai -m window --space 2
end

set id (yabai -m query --windows | jq -r '.[] | select(.app | contains("Slack")) | .id' | head -n 1)
if test -n "$id"; and test "$id" != "null"
    yabai -m window --focus "$id"
    yabai -m window --space 2
end

set id (yabai -m query --windows | jq -r '.[] | select(.app | contains("Ghostty")) | .id' | head -n 1)
if test -n "$id"; and test "$id" != "null"
    yabai -m window --focus "$id"
    yabai -m window --space 1
end
]])

-- ------------------------------------------------------------
-- Edit clipboard content in Neovim
-- ------------------------------------------------------------

local TMUX = "/opt/homebrew/bin/tmux"
local YABAI = "/opt/homebrew/bin/yabai"
local FISH = "/opt/homebrew/bin/fish"
local NVIM = "/opt/homebrew/bin/nvim"
local NVR = "/opt/homebrew/bin/nvr"
local EDIT_SESSION = "hs-edit"
local GHOSTTY_TITLE = "hs_nvim_edit"
local CLIPBOARD_DIR = home .. "/.local/share/hammerspoon"
local NVIM_SOCKET = CLIPBOARD_DIR .. "/nvim.sock"
local MAX_CLIPBOARD_BYTES = 5 * 1024 * 1024
local MAX_CLIPBOARD_FILES = 100
local clipboardLog = hs.logger.new("clipboard-edit", "warning")

local function showClipboardError(message)
  clipboardLog.w(message)
  hs.alert.show(message, 2)
end

local function discardClipboardFile(path)
  if path then
    os.remove(path)
  end
end

local function isPlainTextClipboard()
  local types = hs.pasteboard.pasteboardTypes()
  if not types then
    return true
  end

  for _, pasteboardType in ipairs(types) do
    if pasteboardType:match("^public%.image")
      or pasteboardType:match("^public%.png")
      or pasteboardType:match("^public%.jpeg")
      or pasteboardType:match("^public%.tiff")
      or pasteboardType:match("^com%.apple%.image") then
      return false
    end
  end

  for _, pasteboardType in ipairs(types) do
    if pasteboardType == "public.utf8-plain-text"
      or pasteboardType == "public.text"
      or pasteboardType == "NSStringPboardType" then
      return true
    end
  end

  return false
end

local function hasBinaryControlCharacters(content)
  return content:find("[%z\001-\008\011\012\014-\031\127]") ~= nil
end

local function ensureClipboardDirectory()
  hs.fs.mkdir(home .. "/.local")
  hs.fs.mkdir(home .. "/.local/share")
  return hs.fs.mkdir(CLIPBOARD_DIR) or hs.fs.attributes(CLIPBOARD_DIR) ~= nil
end

local function pruneClipboardFiles()
  local files = {}
  for filename in hs.fs.dir(CLIPBOARD_DIR) do
    if filename:match("^clipboard_%d+_[%w%-]+%.md$") then
      local path = CLIPBOARD_DIR .. "/" .. filename
      local attributes = hs.fs.attributes(path)
      if attributes and attributes.mode == "file" then
        files[#files + 1] = {
          path = path,
          modification = attributes.modification or 0,
        }
      end
    end
  end

  table.sort(files, function(left, right)
    return left.modification > right.modification
  end)

  for index = MAX_CLIPBOARD_FILES + 1, #files do
    os.remove(files[index].path)
  end
end

local function writeClipboardFile(content)
  if not ensureClipboardDirectory() then
    return nil, "Unable to create clipboard directory"
  end

  local slug = content:sub(1, 50)
    :lower()
    :gsub("%s+", "-")
    :gsub("[^%w%-]", "")
    :gsub("%-+", "-")
    :gsub("^%-", "")
    :gsub("%-$", "")
  if slug == "" then
    slug = "untitled"
  end

  local timestamp = tostring(math.floor(hs.timer.secondsSinceEpoch()))
  local filename = "clipboard_" .. timestamp .. "_" .. slug .. ".md"
  local path = CLIPBOARD_DIR .. "/" .. filename
  local collision = 2
  while hs.fs.attributes(path) do
    filename = "clipboard_" .. timestamp .. "_" .. slug .. "-" .. collision .. ".md"
    path = CLIPBOARD_DIR .. "/" .. filename
    collision = collision + 1
  end

  local temporaryPath = path .. ".tmp-" .. tostring(math.floor(hs.timer.secondsSinceEpoch() * 1000))
  local file = io.open(temporaryPath, "wb")
  if not file then
    return nil, "Unable to create clipboard file"
  end

  file:write(content)
  file:close()
  if not os.rename(temporaryPath, path) then
    os.remove(temporaryPath)
    return nil, "Unable to finalize clipboard file"
  end

  pruneClipboardFiles()
  return path
end

local function tmuxSessionExists()
  local result = os.execute(TMUX .. " has-session -t " .. EDIT_SESSION .. " 2>/dev/null")
  return result == true or result == 0
end

local function confirmClipboardCleanup(message)
  local choice = hs.dialog.blockAlert(
    "Clipboard editor cleanup",
    message,
    "Clean up and continue",
    "Cancel",
    "warning"
  )
  return choice == "Clean up and continue"
end

local function cleanupExistingEditorState(sessionExists, socketAttributes)
  local homeAttributes = hs.fs.attributes(home)
  if socketAttributes and socketAttributes.uid ~= homeAttributes.uid then
    showClipboardError("Neovim socket belongs to another user")
    return false
  end

  local details = {}
  if sessionExists then
    details[#details + 1] = "tmux session " .. EDIT_SESSION
  end
  if socketAttributes then
    details[#details + 1] = "Neovim socket " .. NVIM_SOCKET
  end

  if not confirmClipboardCleanup(
    "Existing editor state was found ("
      .. table.concat(details, " and ")
      .. "). Remove it and start a fresh clipboard editor?"
  ) then
    return false
  end

  if sessionExists then
    os.execute(TMUX .. " kill-session -t " .. EDIT_SESSION .. " 2>/dev/null")
  end
  if socketAttributes and not os.remove(NVIM_SOCKET) then
    showClipboardError("Unable to remove existing Neovim socket")
    return false
  end
  return true
end

local function startNvimSession()
  os.remove(NVIM_SOCKET)
  local task = hs.task.new(TMUX, nil, {
    "new-session",
    "-d",
    "-s",
    EDIT_SESSION,
    "-c",
    CLIPBOARD_DIR,
    FISH,
    "-lic",
    "exec " .. NVIM .. " --listen " .. NVIM_SOCKET,
  })
  return task and task:start()
end

local function ensureNvimSession()
  local sessionExists = tmuxSessionExists()
  local socketAttributes = hs.fs.attributes(NVIM_SOCKET)
  local homeAttributes = hs.fs.attributes(home)
  local socketBelongsToUser = socketAttributes and socketAttributes.uid == homeAttributes.uid
  if sessionExists
    and socketAttributes
    and socketAttributes.mode == "socket"
    and socketBelongsToUser then
    return true
  end

  if sessionExists or socketAttributes then
    if not cleanupExistingEditorState(sessionExists, socketAttributes) then
      return false
    end
  end

  return startNvimSession()
end

local function ensureEditorWindowFloating(window, attempts)
  if not window or attempts <= 0 then
    return
  end

  local windowID = window:id()
  if not windowID then
    return
  end

  local query = hs.task.new(YABAI, function(exitCode, standardOutput)
    if exitCode == 0 then
      local details = hs.json.decode(standardOutput)
      if details then
        if not details["is-floating"] then
          hs.task.new(YABAI, nil, {
            "-m",
            "window",
            tostring(windowID),
            "--toggle",
            "float",
          }):start()
        end
        return
      end
    end

    hs.timer.doAfter(0.1, function()
      ensureEditorWindowFloating(window, attempts - 1)
    end)
  end, {
    "-m",
    "query",
    "--windows",
    "--window",
    tostring(windowID),
  })
  if query then
    query:start()
  end
end

local function openGhostty(path)
  local ghostty = hs.application.get("Ghostty") or hs.application.open("Ghostty", 2, true)
  if not ghostty then
    return false
  end

  os.execute(TMUX .. " set-option -t " .. EDIT_SESSION .. " set-titles on")
  os.execute(TMUX .. " set-option -t " .. EDIT_SESSION .. " set-titles-string " .. GHOSTTY_TITLE)

  for _, window in ipairs(ghostty:allWindows()) do
    local title = window:title() or ""
    if title:find(GHOSTTY_TITLE, 1, true) or title:find(EDIT_SESSION, 1, true) then
      window:focus()
      ensureEditorWindowFloating(window, 20)
      return true
    end
  end

  ghostty:activate()
  if not ghostty:selectMenuItem("New Window") then
    return false
  end

  hs.timer.doAfter(0.5, function()
    local newWindow = ghostty:focusedWindow()
    if not newWindow then
      discardClipboardFile(path)
      showClipboardError("Unable to focus new Ghostty window")
      return
    end

    local windowID = newWindow:id()
    if windowID then
      os.execute(YABAI .. " -m window " .. tostring(windowID) .. " --toggle float")
    end

    hs.eventtap.keyStrokes("exec " .. TMUX .. " attach-session -t " .. EDIT_SESSION)
    hs.eventtap.keyStroke({}, "return")
    ensureEditorWindowFloating(newWindow, 20)
  end)

  return true
end

local function openInNvim(path)
  local task = hs.task.new(NVR, function(exitCode)
    if exitCode == 0 then
      hs.alert.show("Opened clipboard in Neovim")
    else
      discardClipboardFile(path)
      showClipboardError("Unable to open clipboard in Neovim")
    end
  end, {
    "--servername",
    NVIM_SOCKET,
    "--nostart",
    "--remote",
    path,
  })
  return task and task:start()
end

local function waitForNvim(path, attempts)
  local socketAttributes = hs.fs.attributes(NVIM_SOCKET)
  if socketAttributes and socketAttributes.mode == "socket" then
    if not openInNvim(path) then
      discardClipboardFile(path)
      showClipboardError("Unable to open Neovim")
      return
    end
    return
  end

  if attempts <= 0 then
    discardClipboardFile(path)
    showClipboardError("Neovim did not start")
    return
  end

  hs.timer.doAfter(0.1, function()
    waitForNvim(path, attempts - 1)
  end)
end

hs.hotkey.bind({"cmd", "alt"}, "E", function()
  if not hs.fs.attributes(NVR) then
    showClipboardError("nvr is not installed; install neovim-remote")
    return
  end

  if not isPlainTextClipboard() then
    showClipboardError("Clipboard is not plain text")
    return
  end

  local content = hs.pasteboard.getContents()
  if not content or content == "" then
    showClipboardError("Clipboard is empty")
    return
  end
  if #content > MAX_CLIPBOARD_BYTES then
    showClipboardError("Clipboard exceeds 5 MiB")
    return
  end
  if hasBinaryControlCharacters(content) then
    showClipboardError("Clipboard contains binary data")
    return
  end

  local path, errorMessage = writeClipboardFile(content)
  if not path then
    showClipboardError(errorMessage)
    return
  end
  if not ensureNvimSession() then
    discardClipboardFile(path)
    showClipboardError("Unable to start tmux Neovim session")
    return
  end
  if not openGhostty(path) then
    discardClipboardFile(path)
    showClipboardError("Unable to open Ghostty")
    return
  end

  waitForNvim(path, 40)
end)

-- ------------------------------------------------------------
-- Manual reload shortcut
-- ------------------------------------------------------------

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "r", function()
  hs.reload()
end)
