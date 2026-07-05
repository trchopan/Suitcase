vim.filetype.add({
  pattern = {
    [".*%.conf"] = function(_, bufnr)
      local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
      line = line:lower()

      if line:match("nginx") then
        return "nginx"
      elseif line:match("%[.*%]") then
        return "dosini"
      else
        return "bash"
      end
    end,
  },
})
