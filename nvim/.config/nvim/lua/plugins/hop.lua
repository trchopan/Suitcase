return {
  "phaazon/hop.nvim",
  config = function()
    require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
  end,
  keys = function()
    local hop = require("hop")
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
