return {
  "phaazon/hop.nvim",
  opts = {
    keys = "etovxqpdygfblzhckisuran",
  },
  keys = function()
    local ok, hop = pcall(require, "hop")
    if not ok then
      return {}
    end
    -- local directions = require('hop.hint').HintDirection
    return {
      {
        mode = { "n", "v" },
        "f",
        function()
          hop.hint_words()
        end,
        desc = "Hop Words",
      },
    }
  end,
}
