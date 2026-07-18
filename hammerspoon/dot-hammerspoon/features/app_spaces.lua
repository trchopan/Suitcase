local M = {}

function M.setup(config, shell)
  shell.bind(config.modifiers.hyper, "m", [[
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
end

return M
