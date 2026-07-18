local M = {}

function M.setup(config)
  local log = hs.logger.new("shell", "warning")

  local function runShell(command, onExit)
    local task = hs.task.new(config.fish, onExit, {"-lc", command})
    if task then
      task:start()
      return true
    end
    return false
  end

  local function run(command)
    return function()
      if not runShell(command, nil) then
        log.e("failed to start shell task")
      end
    end
  end

  local function bind(mods, key, command)
    hs.hotkey.bind(mods, key, run(command))
  end

  return {
    runShell = runShell,
    run = run,
    bind = bind,
  }
end

return M
