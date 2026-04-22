return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Obsidian New" },
    { "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian Quick Switch" },
    { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Obsidian Paste Image" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Obsidian Search" },
    { "<leader>ol", "<cmd>ObsidianLink<cr>", desc = "Obsidian Link" },
    { "<leader>ol", "<cmd>ObsidianLink<cr>", mode = "v", desc = "Obsidian Link" },
    { "<leader>oL", "<cmd>ObsidianLinks<cr>", desc = "Obsidian Links" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian Backlinks" },
    { "<leader>oh", "<cmd>ObsidianFollowLink vsplit<cr>", desc = "Obsidian Follow Link (vsplit)" },
    { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Obsidian Template" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/Chop_vault",
      },
      {
        name = "work",
        path = "~/Documents/Chop_work_vault",
      },
    },
    note_id_func = function(title)
      if title and title ~= "" then
        return title:gsub("%s+", "_"):gsub("[^A-Za-z0-9_]", ""):lower()
      end

      return tostring(os.time())
    end,
    note_frontmatter_func = function(note)
      if note.title then
        note:add_alias(note.title)
      end
      return {
        id = note.id,
        aliases = note.aliases,
      }
    end,
    templates = {
      folder = "~/Documents/Chop_vault/5 - Template",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },
  },
}
