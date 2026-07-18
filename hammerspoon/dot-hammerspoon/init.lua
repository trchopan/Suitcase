local config = require("config")

hs.alert.show("Hammerspoon loaded")

require("lib.spoon_bootstrap").setup(config)

local shell = require("lib.shell").setup(config)
require("features.window_management").setup(config, shell)
require("features.layout_toggle").setup(config, shell)
require("features.app_spaces").setup(config, shell)
require("features.clipboard_editor").setup(config)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "r", function()
  hs.reload()
end)
