local M = {}

function M.setup(config, shell)
  local shiftAlt = config.modifiers.shiftAlt
  local shiftCtrl = config.modifiers.shiftCtrl
  local hyper = config.modifiers.hyper
  local bind = shell.bind

  bind(shiftAlt, "j", [[
set id (yabai -m query --windows --window next | jq -r '.id // empty')
if test -n "$id"
    yabai -m window --focus next
else
    yabai -m window --focus first
end
]])

  bind(shiftAlt, "k", [[
set id (yabai -m query --windows --window prev | jq -r '.id // empty')
if test -n "$id"
    yabai -m window --focus prev
else
    yabai -m window --focus last
end
]])

  bind(shiftAlt, "0", "yabai -m space --balance")
  bind(shiftCtrl, "space", "yabai -m space --mirror y-axis")
  bind(hyper, "1", "yabai -m window --space 1")
  bind(hyper, "2", "yabai -m window --space 2")

  bind(hyper, "3", "yabai -m window --grid 8:12:2:1:8:6")
  bind(hyper, "5", "yabai -m window --grid 1:1:0:0:1:1")
  bind(hyper, "4", "yabai -m window --grid 1:2:0:0:1:1")
  bind(hyper, "6", "yabai -m window --grid 1:2:1:0:1:1")
  bind(hyper, "9", "yabai -m window --grid 1:3:2:0:1:1")

  bind(shiftAlt, "return", "yabai -m window --swap first")
  bind(hyper, "j", "yabai -m window --swap next")
  bind(hyper, "k", "yabai -m window --swap prev")
  bind(hyper, "up", "yabai -m window --move rel:0:-100")
  bind(hyper, "down", "yabai -m window --move rel:0:100")
  bind(hyper, "left", "yabai -m window --move rel:-100:0")
  bind(hyper, "right", "yabai -m window --move rel:100:0")

  bind(hyper, "h", "yabai -m window --display prev")
  bind(hyper, "l", "yabai -m window --display next")
  bind(shiftAlt, 27, "yabai -m window --resize bottom_right:-75:0")
  bind(shiftAlt, 24, "yabai -m window --resize bottom_right:75:0")
  bind(hyper, 27, "yabai -m window --resize bottom_right:0:-75")
  bind(hyper, 24, "yabai -m window --resize bottom_right:0:75")

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
  bind(hyper, "x", "yabai -m window --toggle float")
end

return M
