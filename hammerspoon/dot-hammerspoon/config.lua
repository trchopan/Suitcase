local home = os.getenv("HOME")

return {
  home = home,
  fish = "/opt/homebrew/bin/fish",
  tmux = "/opt/homebrew/bin/tmux",
  yabai = "/opt/homebrew/bin/yabai",
  nvim = "/opt/homebrew/bin/nvim",
  nvr = "/opt/homebrew/bin/nvr",
  spoonsDir = home .. "/.hammerspoon/Spoons",
  clipboardDir = home .. "/.local/share/hammerspoon/clipboard",
  editSession = "hs-edit",
  ghosttyTitle = "hs_nvim_edit",
  nvimSocket = home .. "/.local/share/hammerspoon/nvim.sock",
  maxClipboardBytes = 5 * 1024 * 1024,
  maxClipboardFiles = 100,
  modifiers = {
    shiftAlt = {"shift", "alt"},
    shiftCtrl = {"shift", "ctrl"},
    hyper = {"shift", "alt", "ctrl"},
  },
}
