return {
  "phaazon/hop.nvim",
  config = {
    keys = 'etovxqpdygfblzhckisuran',
  },
  keys = function()
    local ok, hop = pcall(require, "hop")
    if not ok then
      return {}
    end
    local directions = require('hop.hint').HintDirection
    return {
      { mode = { "n", "v" }, "<space>", function ()
          hop.hint_words()
      end, desc = "Hop Words" },
      {
        mode = { "n", "v" },
        "f",
        function()
          hop.hint_char1({ direction = directions.AFTER_CURSOR })
        end,
        desc = "Hop Char1 After"
      },
      {
        mode = { "n", "v" },
        "F",
        function()
          hop.hint_char1({ direction = directions.BEFORE_CURSOR })
        end,
        desc = "Hop Char1 Before"
      }
    }
  end,
}
