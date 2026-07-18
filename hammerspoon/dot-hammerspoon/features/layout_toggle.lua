local M = {}

function M.setup(config, shell)
  local log = hs.logger.new("layout", "warning")
  local lastToggleAt = 0
  local debounceSeconds = 0.2

  hs.hotkey.bind(config.modifiers.hyper, 44, function()
    local now = hs.timer.secondsSinceEpoch()
    if now - lastToggleAt < debounceSeconds then
      return
    end
    lastToggleAt = now
    log.i("toggle layout/borders")

    local ok = shell.runShell([[
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
      log.i("toggle layout/borders done")
    end)

    if not ok then
      log.e("failed to start layout/borders task")
    end
  end)
end

return M
