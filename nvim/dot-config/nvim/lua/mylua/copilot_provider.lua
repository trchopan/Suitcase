local M = {}

local providers = {
  personal = true,
  work = true,
}

local function config_path()
  local xdg_config = vim.env.XDG_CONFIG_HOME
  if xdg_config and xdg_config ~= "" then
    return xdg_config
  end
  return vim.fn.expand("~/.config")
end

local function copilot_dir()
  return config_path() .. "/github-copilot"
end

local function provider_file(provider)
  return copilot_dir() .. "/apps-" .. provider .. ".json"
end

local function active_file()
  return copilot_dir() .. "/apps.json"
end

local function notify(msg, level)
  vim.notify("[Copilot] " .. msg, level or vim.log.levels.INFO)
end

local function ensure_copilot_loaded()
  if package.loaded["copilot"] then
    return true
  end

  local ok_lazy, lazy = pcall(require, "lazy")
  if not ok_lazy then
    notify("lazy.nvim is not available", vim.log.levels.ERROR)
    return false
  end

  lazy.load({ plugins = { "copilot.lua" } })
  return package.loaded["copilot"] ~= nil
end

local function reload_copilot_client()
  pcall(vim.cmd, "Copilot disable")
  pcall(vim.cmd, "Copilot enable")
end

function M.switch(provider)
  if not providers[provider] then
    notify("Unknown provider '" .. tostring(provider) .. "'. Use: personal, work", vim.log.levels.ERROR)
    return
  end

  local source = provider_file(provider)
  if vim.fn.filereadable(source) == 0 then
    notify("Missing provider credentials: " .. source, vim.log.levels.ERROR)
    return
  end

  vim.fn.mkdir(copilot_dir(), "p")
  local lines = vim.fn.readfile(source)
  vim.fn.writefile(lines, active_file())

  vim.g.copilot_enabled = 1

  if not ensure_copilot_loaded() then
    return
  end

  reload_copilot_client()
  notify("Provider switched to '" .. provider .. "' and Copilot enabled")
end

function M.save(provider)
  if not providers[provider] then
    notify("Unknown provider '" .. tostring(provider) .. "'. Use: personal, work", vim.log.levels.ERROR)
    return
  end

  local active = active_file()
  if vim.fn.filereadable(active) == 0 then
    notify("Active credentials not found: " .. active, vim.log.levels.ERROR)
    return
  end

  vim.fn.mkdir(copilot_dir(), "p")
  local lines = vim.fn.readfile(active)
  vim.fn.writefile(lines, provider_file(provider))
  notify("Saved current credentials to provider '" .. provider .. "'")
end

function M.disable()
  vim.g.copilot_enabled = 0
  pcall(vim.cmd, "Copilot disable")
end

function M.setup_command()
  vim.api.nvim_create_user_command("CopilotProvider", function(opts)
    local args = vim.split(vim.trim(opts.args or ""), "%s+", { trimempty = true })
    local provider = args[1]
    local action = args[2]

    if not provider then
      notify("Usage: CopilotProvider <personal|work> [save]", vim.log.levels.ERROR)
      return
    end

    if action == nil then
      M.switch(provider)
      return
    end

    if action == "save" then
      M.save(provider)
      return
    end

    notify("Usage: CopilotProvider <personal|work> [save]", vim.log.levels.ERROR)
  end, {
    nargs = "+",
    complete = function(_, line)
      local has_space = line:match("%s$") ~= nil
      local params = vim.split(line, "%s+", { trimempty = true })
      if #params == 1 then
        return { "personal", "work" }
      end
      if #params == 2 and not has_space then
        return vim.tbl_filter(function(item)
          return item:find("^" .. params[2]) ~= nil
        end, { "personal", "work" })
      end
      if #params == 2 and has_space then
        return { "save" }
      end
      if #params == 3 and not has_space then
        return vim.tbl_filter(function(item)
          return item:find("^" .. params[3]) ~= nil
        end, { "save" })
      end
      return {}
    end,
  })
end

return M
