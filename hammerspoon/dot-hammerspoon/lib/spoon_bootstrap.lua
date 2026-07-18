local M = {}

function M.setup(config)
  local function ensureSpoon(name, zipUrl)
    local spoonPath = string.format("%s/%s.spoon", config.spoonsDir, name)
    local initPath = spoonPath .. "/init.lua"

    if hs.fs.attributes(initPath) then
      return true
    end

    hs.alert.show(string.format("Repairing %s.spoon", name), 1)
    hs.fs.mkdir(config.spoonsDir)

    local zipPath = string.format("/tmp/%s.spoon.zip", name)
    local command = string.format(
      "rm -rf %q && curl -fsSL %q -o %q && /usr/bin/unzip -oq %q -d %q",
      spoonPath,
      zipUrl,
      zipPath,
      zipPath,
      config.spoonsDir
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
end

return M
