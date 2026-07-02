-- ~/.hammerspoon/init.lua

hs.alert.show("Hammerspoon loaded")

-- ------------------------------------------------------------
-- Shell runner
-- ------------------------------------------------------------

local fish = "/opt/homebrew/bin/fish"

local function run(command)
  return function()
    hs.task.new(fish, nil, {"-lc", command}):start()
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

bind(hyper, 44, [[
set layout (yabai -m query --spaces | grep float)
if test -z "$layout"
    yabai -m config layout float
else
    yabai -m config layout bsp
end
]])

-- ------------------------------------------------------------
-- Toggle borders
-- ------------------------------------------------------------

bind(hyper, "n", [[
set border_pid (pgrep -f borders)

if test -n "$border_pid"
    killall borders
    yabai -m config top_padding 0
    yabai -m config bottom_padding 0
    yabai -m config left_padding 0
    yabai -m config right_padding 0
    yabai -m config window_gap 0
else
    borders active_color=0xff00FF31 inactive_color=0x00000000 width=5.0 &
    yabai -m config top_padding 5
    yabai -m config bottom_padding 5
    yabai -m config left_padding 5
    yabai -m config right_padding 5
    yabai -m config window_gap 5
end
]])

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
-- Ghostty-specific remaps
--
-- skhd:
--   ctrl - tab        in Ghostty -> shift - l
--   shift + ctrl - tab in Ghostty -> shift - h
-- ------------------------------------------------------------

local function frontmostAppName()
  local app = hs.application.frontmostApplication()
  if app then
    return app:name()
  end
  return ""
end

hs.hotkey.bind({"ctrl"}, "tab", function()
  if frontmostAppName() == "Ghostty" then
    hs.eventtap.keyStroke({"shift"}, "l", 0)
  end
end)

hs.hotkey.bind({"shift", "ctrl"}, "tab", function()
  if frontmostAppName() == "Ghostty" then
    hs.eventtap.keyStroke({"shift"}, "h", 0)
  end
end)

-- ------------------------------------------------------------
-- Manual reload shortcut
-- ------------------------------------------------------------

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "r", function()
  hs.reload()
end)
