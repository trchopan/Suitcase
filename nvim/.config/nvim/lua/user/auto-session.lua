local ok, session = pcall(require, "auto-session")
if not ok then
    return
end

session.setup {
    log_level = "error",
    auto_session_suppress_dirs = { "~/", "~/Sync", "~/Downloads", "~/Documents", "/" },
    pre_save_cmds = {"NvimTreeClose"},
}
